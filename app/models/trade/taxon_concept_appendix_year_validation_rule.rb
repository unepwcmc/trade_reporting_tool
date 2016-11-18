class Trade::TaxonConceptAppendixYearValidationRule < Trade::InclusionValidationRule

  def validation_errors_for_shipment(shipment)
    return nil unless shipment_in_scope?(shipment)
    # if it is, check if it has a match in valid values view
    v = Arel::Table.new(valid_values_view)
    appendix_node = v['appendix'].eq(
      Arel::Nodes::Quoted.new(shipment.appendix)
    )
    effective_from = Arel::Nodes::NamedFunction.new(
      'DATE_PART',
      [Arel::Nodes::Quoted.new('year'), v['effective_from']]
    )
    effective_to = Arel::Nodes::NamedFunction.new(
      'DATE_PART',
      [Arel::Nodes::Quoted.new('year'), v['effective_to']]
    )
    year_node = effective_from.lteq(shipment.year).and(
      effective_to.gteq(shipment.year).or(effective_to.eq(nil))
    )
    taxon_concept_node = v['taxon_concept_id'].eq(
      Arel::Nodes::Quoted.new(shipment.taxon_concept_id)
    )
    conditions = appendix_node.and(year_node).and(taxon_concept_node)
    return nil if Trade::Shipment.find_by_sql(v.project(Arel.star).where(conditions)).any?
    error_message
  end

  private

  def year_join_node(s, v)
    sandbox_year = Arel::Nodes::NamedFunction.new(
      'CAST',
      [s['year'].as('INT')]
    )
    effective_from = Arel::Nodes::NamedFunction.new(
      'DATE_PART',
      [Arel::Nodes::Quoted.new('year'), v[:effective_from]]
    )
    effective_to = Arel::Nodes::NamedFunction.new(
      'DATE_PART',
      [Arel::Nodes::Quoted.new('year'), v[:effective_to]]
    )
    effective_from.lteq(sandbox_year).and(
      effective_to.gteq(sandbox_year).or(effective_to.eq(nil))
    )
  end

  def taxon_concept_join_node(s, v)
    s['taxon_concept_id'].eq(v['taxon_concept_id'])
  end

  def appendix_join_node(s, v)
    s['appendix'].eq(v['appendix'])
  end

  # Difference from superclass: rather than equality, check if appendix
  # is contained in valid appendix array (to allow for split listings)
  def matching_records_arel(table_name)
    s = Arel::Table.new("#{table_name}_view")
    v = Arel::Table.new(valid_values_view)
    join_nodes = [
      appendix_join_node(s, v),
      year_join_node(s, v),
      taxon_concept_join_node(s, v)
    ]
    valid_values = s.project(s[Arel.star]).join(v).on(join_nodes.inject(&:and))
    not_null_nodes = column_names.map do |c|
      s[c].not_eq(nil)
    end
    s.project(Arel.star).where(not_null_nodes.inject(&:and)).except(valid_values)
  end

end
