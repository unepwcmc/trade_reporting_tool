shared_context :validation_rules_helpers do

  def create_taxon_name_presence_validation
    FactoryGirl.create(
      :presence_validation_rule,
      :column_names => ['taxon_name']
    )
  end

  def create_year_format_validation
    FactoryGirl.create(
      :format_validation_rule,
      :column_names => ['year'],
      :format_re => '^\d{4}$',
      :is_strict => true
    )
  end

  def create_quantity_numericality_validation
    FactoryGirl.create(
      :numericality_validation_rule,
      :column_names => ['quantity'],
      :is_strict => true
    )
  end

  def create_taxon_concept_validation
    FactoryGirl.create(
      :inclusion_validation_rule,
      column_names: ['taxon_name'],
      valid_values_view: 'valid_taxon_name_view',
      is_strict: true
    )
  end

  def create_taxon_concept_appendix_year_validation
    FactoryGirl.create(:taxon_concept_appendix_year_validation_rule,
      :is_primary => false,
      :is_strict => true
    )
  end

  def create_term_unit_validation
    FactoryGirl.create(:inclusion_validation_rule,
      :column_names => ['term_code', 'unit_code'],
      :valid_values_view => 'valid_term_unit_view',
      :is_primary => false
    )
  end

  def create_term_purpose_validation
    FactoryGirl.create(:inclusion_validation_rule,
      :column_names => ['term_code', 'purpose_code'],
      :valid_values_view => 'valid_term_purpose_view',
      :is_primary => false
    )
  end

  def create_taxon_concept_term_validation
    FactoryGirl.create(:inclusion_validation_rule,
      :column_names => ['taxon_concept_id', 'term_code'],
      :valid_values_view => 'valid_taxon_concept_term_view',
      :is_primary => false,
      :is_strict => true
    )
  end

  def create_taxon_concept_country_of_origin_validation
    FactoryGirl.create(:inclusion_validation_rule,
      :scope => {
        :rank => { :inclusion => [Rank::SPECIES, Rank::SUBSPECIES] },
        :source_code => { :inclusion => ['W'] },
        :country_of_origin => { :exclusion => ['XX'] }
      },
      :column_names => ['taxon_concept_id', 'country_of_origin'],
      :valid_values_view => 'valid_taxon_concept_country_of_origin_view',
      :is_primary => false,
      :is_strict => true
    )
  end

  def create_taxon_concept_exporter_validation
    FactoryGirl.create(:inclusion_validation_rule,
      :scope => {
        :rank => { :inclusion => [Rank::SPECIES, Rank::SUBSPECIES] },
        :source_code => { :inclusion => ['W'] },
        :country_of_origin => { :blank => true },
        :exporter => { :exclusion => ['XX'] }
      },
      :column_names => ['taxon_concept_id', 'exporter'],
      :valid_values_view => 'valid_taxon_concept_exporter_view',
      :is_primary => false,
      :is_strict => true
    )
  end

  def create_exporter_country_of_origin_validation
    FactoryGirl.create(:distinct_values_validation_rule,
      :column_names => ['exporter', 'country_of_origin'],
      :is_primary => false,
      :is_strict => true
    )
  end

  def create_exporter_importer_validation
    FactoryGirl.create(:distinct_values_validation_rule,
      :column_names => ['exporter', 'importer'],
      :is_primary => false,
      :is_strict => true
    )
  end

  def create_taxon_concept_source_validation
    FactoryGirl.create(:taxon_concept_source_validation_rule,
      :column_names => ['taxon_concept_id', 'source_code'],
      :is_primary => false,
      :is_strict => true
    )
  end

end
