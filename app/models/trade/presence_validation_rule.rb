class Trade::PresenceValidationRule < Trade::ValidationRule

  def error_message
    column_names.join(', ') + ' cannot be blank'
  end

  # Returns records where the specified columns are NULL.
  # In case more than one column is specified, predicates are combined
  # using AND.
  def matching_records(annual_report_upload)
    sandbox_klass = annual_report_upload.sandbox.ar_klass
    s = sandbox_klass.arel_table
    arel_nodes = column_names.map do |c|
      s[c].eq(nil)
    end
    sandbox_klass.select('*').where(arel_nodes.inject(&:and))
  end
end
