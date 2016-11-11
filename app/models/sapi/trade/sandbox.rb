module Sapi
  class Trade::Sandbox
    attr_reader :table_name
    def initialize(annual_report_upload)
      @annual_report_upload = annual_report_upload
      @csv_file_path = @annual_report_upload.csv_source_file.try(:current_path)
      @table_name = "trade_sandbox_#{@annual_report_upload.id}"
      @ar_klass = Trade::SandboxTemplate.ar_klass(@table_name)
    end

    def copy
      create_target_table
      copy_csv_to_target_table
      @ar_klass.sanitize
    end

    def copy_data(submitted_data)
      create_target_table
      submitted_data[:CITESReport].each do |row|
        row = row[:CITESReportRow]
        values = {
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
          import_permit: row[:ImportPermitId]
        }
        @ar_klass.create(values)
      end
      @ar_klass.sanitize
    end

    def copy_from_sandbox_to_shipments
      success = true
      Trade::Shipment.transaction do
        pg_result = Trade::SandboxTemplate.connection.execute(
          Trade::SandboxTemplate.send(:sanitize_sql_array, [
            'SELECT * FROM copy_transactions_from_sandbox_to_shipments(?)',
            @annual_report_upload.id
          ])
        )
        moved_rows_cnt = pg_result.first['copy_transactions_from_sandbox_to_shipments'].to_i
        if moved_rows_cnt < 0
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

    def shipments
      @ar_klass.order(:id).all
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
          Trade::SandboxTemplate.create_indexes_stmt(@table_name)
        )
        Trade::SandboxTemplate.connection.execute(
          Trade::SandboxTemplate.create_view_stmt(@table_name, @annual_report_upload.id)
        )
      end
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
end