class Trade::NumericalityValidationRule < Trade::ValidationRule

  def error_message
    column_names.join(', ') + ' must be a number'
  end

  private

  # Returns records that do not pass the ISNUMERIC test for all columns
  # specified in column_names.
  def matching_records(annual_report_upload)
    sandbox_klass = annual_report_upload.sandbox.ar_klass
    s = sandbox_klass.arel_table
    arel_columns = column_names.map { |c| Arel::Attribute.new(s, c) }
    isnumeric_columns = arel_columns.map do |a|
      Arel::Nodes::NamedFunction.new 'isnumeric', [a]
    end
    arel_nodes = isnumeric_columns.map { |c| c.eq(false) }
    sandbox_klass.select('*').where(arel_nodes.inject(&:or))
  end
end
