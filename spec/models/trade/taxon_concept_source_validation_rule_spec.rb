require "rails_helper"

RSpec.describe Trade::TaxonConceptSourceValidationRule, type: :model do

  include_context :validation_rules_helpers

  let!(:canis_lupus) {
    FactoryGirl.create(
      :taxon_concept,
      taxon_name: FactoryGirl.create(:taxon_name, scientific_name: 'Canis lupus'),
      data: {kingdom_name: 'Animalia'}
    )
  }

  let(:aru) {
    aru = FactoryGirl.create(:annual_report_upload)
    aru.sandbox.send(:create_target_table)
    aru
  }

  let(:sandbox_klass) {
    aru.sandbox.ar_klass
  }

  describe :matching_records_for_aru_and_error do
    let(:validation_rule) {
      create_taxon_concept_source_validation
    }
    before(:each) do
      @shipment1 = sandbox_klass.create(
        source_code: 'W',
        taxon_name: 'Canis lupus'
      )
      @shipment2 = sandbox_klass.create(
        source_code: 'A',
        taxon_name: 'Canis lupus'
      )
      @validation_error = FactoryGirl.create(
        :validation_error,
        annual_report_upload_id: aru.id,
        validation_rule_id: validation_rule.id,
        matching_criteria: {source_code: 'A', taxon_concept_id: canis_lupus.id}.to_json
      )
    end
    specify {
      expect(
        validation_rule.matching_records_for_aru_and_error(
          aru,
          @validation_error
        )
      ).to eq([@shipment2])
    }
  end

end
