FactoryGirl.define do
  factory :validation_rule, class: Trade::ValidationRule do
    type 'Trade::ValidationRule'
    column_names []
    is_primary true
    is_strict false
    run_order 1

    factory :presence_validation_rule, class: Trade::PresenceValidationRule
    factory :numericality_validation_rule, class: Trade::NumericalityValidationRule
    factory :format_validation_rule, class: Trade::FormatValidationRule do
      format_re '^\w+$'
    end
    factory :inclusion_validation_rule, class: Trade::InclusionValidationRule do
      valid_values_view 'valid_taxon_concept_view'
    end
    factory :distinct_values_validation_rule,
      class: Trade::DistinctValuesValidationRule
    factory :taxon_concept_appendix_year_validation_rule,
      class: Trade::TaxonConceptAppendixYearValidationRule do
      column_names ['taxon_concept_id', 'appendix', 'year']
      valid_values_view 'valid_taxon_concept_appendix_year_mview'
    end
    factory :taxon_concept_source_validation_rule,
      class: Trade::TaxonConceptSourceValidationRule

  end
end
