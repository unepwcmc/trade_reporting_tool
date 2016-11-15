class Trade::SandboxTemplate < Sapi::Base

  self.table_name = :trade_sandbox_template

  COLUMNS_IN_CSV_ORDER = [
    "appendix", "species_name", "term_code", "quantity", "unit_code",
    "trading_partner", "country_of_origin", "import_permit", "export_permit",
    "origin_permit", "purpose_code", "source_code", "year"
  ]
  CSV_IMPORTER_COLUMNS = COLUMNS_IN_CSV_ORDER
  CSV_EXPORTER_COLUMNS = COLUMNS_IN_CSV_ORDER - ['import_permit']
  IMPORTER_COLUMNS = CSV_IMPORTER_COLUMNS.map { |c| c == 'species_name' ? 'taxon_name' : c }
  EXPORTER_COLUMNS = CSV_EXPORTER_COLUMNS.map { |c| c == 'species_name' ? 'taxon_name' : c }

  # Dynamically define AR class for table_name
  # (unless one exists already)
  def self.ar_klass(table_name)
    klass_name = table_name.camelize
    begin
      "Trade::#{klass_name}".constantize
    rescue NameError
      klass = Class.new(Sapi::Base) do
        self.table_name = table_name
        include ActiveModel::ForbiddenAttributesProtection
        # belongs_to :taxon_concept
        # belongs_to :reported_taxon_concept, :class_name => TaxonConcept

        def sanitize
          self.class.sanitize(self.id)
        end

        def self.sanitize(id = nil)
          updates = 
            'appendix = UPPER(SQUISH_NULL(appendix)),
            year = SQUISH_NULL(year),
            term_code = UPPER(SQUISH_NULL(term_code)),
            unit_code = UPPER(SQUISH_NULL(unit_code)),
            purpose_code = UPPER(SQUISH_NULL(purpose_code)),
            source_code = UPPER(SQUISH_NULL(source_code)),
            quantity = SQUISH_NULL(quantity),
            trading_partner = UPPER(SQUISH_NULL(trading_partner)),
            country_of_origin = UPPER(SQUISH_NULL(country_of_origin)),
            import_permit = UPPER(SQUISH_NULL(import_permit)),
            export_permit = UPPER(SQUISH_NULL(export_permit)),
            origin_permit = UPPER(SQUISH_NULL(origin_permit))'
          if id.blank?
            update_all(updates)
          else
            where(id: id).update_all(updates)
          end
          # resolve reported & accepted taxon
          connection.execute(
            sanitize_sql_array([
              'SELECT * FROM resolve_taxa_in_sandbox(?, ?)',
              @table_name,
              id
            ])
          )
        end

        def save(attributes = {})
          super(attributes)
          sanitize
        end

        def destroy
          super
          self.class.update_all(updated_at: Time.now) # bump timestamp to ensure errors refreshed
        end

        def self.records_for_batch_operation(validation_error, annual_report_upload)
          vr = validation_error.validation_rule
          joins(
            <<-SQL
            JOIN (
              #{vr.matching_records_for_aru_and_error(annual_report_upload, validation_error).to_sql}
            ) matching_records on #{table_name}.id = matching_records.id
            SQL
          )
        end

        def self.update_batch(updates, validation_error, annual_report_upload)
          return unless updates
          updates[:updated_at] = Time.now
          records_for_batch_operation(validation_error, annual_report_upload).
            update_all(updates)
          sanitize
        end

        def self.destroy_batch(validation_error, annual_report_upload)
          records_for_batch_operation(validation_error, annual_report_upload).
            each(&:delete)
          update_all(updated_at: Time.now) # bump timestamp to ensure errors refreshed
        end

      end
      Trade.const_set(klass_name, klass)
    end
  end

  private

  def self.create_table_stmt(target_table_name)
    sql = <<-SQL
      CREATE TABLE #{target_table_name} (PRIMARY KEY(id))
      INHERITS (#{table_name})
    SQL
  end

  def self.create_indexes_stmt(target_table_name)
    sql = <<-SQL
      CREATE INDEX ON #{target_table_name} (trading_partner);
      CREATE INDEX ON #{target_table_name} (term_code);
      CREATE INDEX ON #{target_table_name} (taxon_name);
      CREATE INDEX ON #{target_table_name} (taxon_concept_id);
      CREATE INDEX ON #{target_table_name} (appendix);
      CREATE INDEX ON #{target_table_name} (quantity);
      CREATE INDEX ON #{target_table_name} (source_code);
      CREATE INDEX ON #{target_table_name} (purpose_code);
      CREATE INDEX ON #{target_table_name} (unit_code);
      CREATE INDEX ON #{target_table_name} (country_of_origin);
    SQL
  end

  def self.create_view_stmt(target_table_name, idx)
    sanitize_sql_array([
      "SELECT * FROM create_trade_sandbox_view(?, ?)",
      target_table_name,
      idx
    ])
  end

  def self.drop_stmt(target_table_name)
    sql = <<-SQL
      DROP TABLE IF EXISTS #{target_table_name} CASCADE
    SQL
  end

  def self.copy_stmt(target_table_name, csv_file_path, columns_in_csv_order)
    sql = <<-PSQL
      \\COPY #{target_table_name} (#{columns_in_csv_order.join(', ')})
      FROM ?
      WITH DELIMITER ','
      ENCODING 'utf-8'
      CSV HEADER;
    PSQL
    sanitize_sql_array([sql, csv_file_path])
  end
end
