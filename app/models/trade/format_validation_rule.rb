class Trade::FormatValidationRule < Trade::ValidationRule

  def error_message
    column_names.join(', ') + ' must be formatted as ' + format_re
  end

  private

  # Returns records that do not pass the regex test for all columns
  # specified in column_names.
  def matching_records(annual_report_upload)
    sandbox_klass = annual_report_upload.sandbox.ar_klass
    s = sandbox_klass.arel_table
    arel_nodes = column_names.map { |c| "#{c} !~ '#{format_re}'" }
    sandbox_klass.select('*').where(arel_nodes.inject(&:or))
  end
end
