class Trade::DistinctValuesValidationRule < Trade::InclusionValidationRule
  # TODO: should have a validation for at least 2 column names

  def validation_errors_for_shipment(shipment)
    return nil unless shipment_in_scope?(shipment)
    # if it is, check if validated columns are not equal
    distinct_values = true
    shipments_columns.each do |c1|
      shipments_columns.each do |c2|
        distinct_values = false if c1 != c2 && shipment.send(c1) == shipment.send(c2)
      end
    end
    return nil if distinct_values
    error_message
  end

  private

  # Returns records that have the same value for both columns
  # specified in column_names. If more then 2 columns are specified,
  # only the first two are taken into consideration.
  def matching_records_arel(table_name)
    s = Arel::Table.new("#{table_name}_view")
    arel_columns = column_names.map { |c| Arel::Attribute.new(s, c) }
    first_column = arel_columns.shift
    second_column = arel_columns.shift
    s.project(s[Arel.star]).where(first_column.eq(second_column))
  end
end
