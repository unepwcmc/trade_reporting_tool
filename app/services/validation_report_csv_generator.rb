require 'csv'
class ValidationReportCsvGenerator

  def self.call(aru)
    data_columns = if aru.reported_by_exporter?
      Trade::SandboxTemplate::EXPORTER_COLUMNS
    else
      Trade::SandboxTemplate::IMPORTER_COLUMNS
    end
    tempfile = Tempfile.new(["validation_report_#{aru.id}", ".csv"], Rails.root.join('tmp'))
    CSV.open(tempfile, 'w', headers: true) do |csv|
      csv << data_columns + ['ERRORS']
      aru.validation_report.each do |index, data_and_errors|
        data = data_columns.map do |c|
          data_and_errors['data'][c]
        end
        errors = data_and_errors['errors'] || []
        csv << data + errors
      end
    end
    tempfile
  end

end
