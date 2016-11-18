class Trade::TaxonConceptSourceValidationRule < Trade::InclusionValidationRule

  INVALID_KINGDOM_SOURCE = {
    'ANIMALIA' => ['A'],
    'PLANTAE' => ['C', 'R']
  }

  def validation_errors_for_shipment(shipment)
    return nil unless shipment.source && (
      shipment.taxon_concept &&
      shipment.taxon_concept.data['kingdom_name'] == 'Animalia' &&
      INVALID_KINGDOM_SOURCE['ANIMALIA'].include?(shipment.source.code) ||
      shipment.taxon_concept &&
      shipment.taxon_concept.data['kingdom_name'] == 'Plantae' &&
      INVALID_KINGDOM_SOURCE['PLANTAE'].include?(shipment.source.code)
    )
    error_message
  end

  private

  def matching_records_arel(table_name)
    s = Arel::Table.new("#{table_name}_view")
    tc = Arel::Table.new('taxon_concepts')
    t = Arel::Table.new('taxonomies')

    upper_kingdom_name = Arel::Nodes::NamedFunction.new(
      "UPPER",
      [Arel::Nodes::SqlLiteral.new("taxon_concepts.data->'kingdom_name'")]
    )

    arel = s.project(
      s['id'],
      s['taxon_concept_id'],
      s['source_code'],
      s['accepted_taxon_name']
    ).join(tc).on(
      s['taxon_concept_id'].eq(tc['id'])
    ).join(t).on(
      tc['taxonomy_id'].eq(t['id']).and(t['name'].eq(Arel::Nodes::Quoted.new('CITES_EU')))
    ).where(
      upper_kingdom_name.eq(Arel::Nodes::Quoted.new('ANIMALIA')).and(
        s['source_code'].in(
          INVALID_KINGDOM_SOURCE['ANIMALIA']
        )
      ).or(
        upper_kingdom_name.eq(Arel::Nodes::Quoted.new('PLANTAE')).and(
          s['source_code'].in(
            INVALID_KINGDOM_SOURCE['PLANTAE']
          )
        )
      )
    )
  end
end
