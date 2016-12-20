class Trade::Sandbox
  attr_reader :table_name, :ar_klass, :moved_rows_cnt

  def initialize(annual_report_upload)
    @annual_report_upload = annual_report_upload
    @csv_file_path = @annual_report_upload.csv_source_file.try(:current_path)
    @table_name = "trade_sandbox_#{@annual_report_upload.id}"
    @ar_klass = Trade::SandboxTemplate.ar_klass(@table_name)
    @moved_rows_cnt = -1
  end

  def copy
    create_target_table
    copy_csv_to_target_table
    @ar_klass.sanitize
  end

  def copy_data(submitted_data)
    create_target_table
    @ar_klass.bulk_insert do |worker|
      submitted_data[:CITESReport].each do |row|
        row = row[:CITESReportRow]
        worker.add({
          trading_partner: row[:TradingPartnerId],
          year: row[:Year],
          taxon_name: row[:ScientificName],
          appendix: row[:Appendix],
          term_code: row[:TermCode],
          quantity: row[:Quantity],
          unit_code: row[:UnitCode],
          source_code: row[:SourceCode],
          purpose_code: row[:PurposeCode],
          country_of_origin: row[:OriginCountryId],
          origin_permit: row[:OriginPermitId],
          export_permit: row[:ExportPermitId],
          import_permit: row[:ImportPermitId],
          created_by_id: @annual_report_upload.created_by_id,
          updated_by_id: @annual_report_upload.updated_by_id,
          epix_created_by_id: @annual_report_upload.epix_created_by_id,
          epix_updated_by_id: @annual_report_upload.epix_updated_by_id,
          created_at: @annual_report_upload.created_at,
          updated_at: @annual_report_upload.updated_at,
          epix_created_at: @annual_report_upload.epix_created_at,
          epix_updated_at: @annual_report_upload.epix_updated_at
        })
      end
    end
    @ar_klass.sanitize
    create_target_table_indexes
  end

  def copy_from_sandbox_to_shipments(submitter)
    success = true
    # is_a? doesn't always return false for some reason
    submitter_type = submitter.class.to_s.split(':').first
    Trade::SandboxTemplate.transaction do
      pg_result = Trade::SandboxTemplate.connection.execute(
        Trade::SandboxTemplate.send(:sanitize_sql_array, [
          'SELECT * FROM copy_transactions_from_sandbox_to_shipments(?, ?, ?)',
          @annual_report_upload.id,
          submitter_type,
          submitter.id
        ])
      )
      @moved_rows_cnt = pg_result.first['copy_transactions_from_sandbox_to_shipments'].to_i
      if @moved_rows_cnt < 0
        # if -1 returned, not all rows have been moved
        self.errors[:base] << "Submit failed, could not save all rows."
        success = false
        raise ActiveRecord::Rollback
      end
    end
    success
  end

  def destroy
    Trade::SandboxTemplate.connection.execute(
      Trade::SandboxTemplate.drop_stmt(@table_name)
    )
  end

  def shipments(validation_error=nil)
    if validation_error
      validation_error.validation_rule.
        matching_records_for_aru_and_error(@annual_report_upload, validation_error).
        order(:id)
    else
      @ar_klass.order(:id).all
    end
  end

  def shipments=(new_shipments)
    # TODO: handle errors
    new_shipments.each do |shipment|
      s = @ar_klass.find_by_id(shipment.delete('id'))
      s.delete_or_update_attributes(shipment)
    end
  end

  private

  def create_target_table
    unless Trade::SandboxTemplate.connection.data_source_exists? @table_name
      Trade::SandboxTemplate.connection.execute(
        Trade::SandboxTemplate.create_table_stmt(@table_name)
      )
      Trade::SandboxTemplate.connection.execute(
        Trade::SandboxTemplate.create_view_stmt(@table_name, @annual_report_upload.id)
      )
    end
  end

  def create_target_table_indexes
    Trade::SandboxTemplate.connection.execute(
      Trade::SandboxTemplate.create_indexes_stmt(@table_name)
    )
  end

  def copy_csv_to_target_table
    require 'psql_command'
    columns_in_csv_order =
      if (@annual_report_upload.point_of_view == 'E')
        Trade::SandboxTemplate::EXPORTER_COLUMNS
      else
        Trade::SandboxTemplate::IMPORTER_COLUMNS
      end
    cmd = Trade::SandboxTemplate.copy_stmt(@table_name, @csv_file_path, columns_in_csv_order)
    PsqlCommand.new(cmd).execute
  end
end
