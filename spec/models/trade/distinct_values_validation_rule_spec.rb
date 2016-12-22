require "rails_helper"

RSpec.describe Trade::DistinctValuesValidationRule, type: :model do

  include_context :validation_rules_helpers

  let(:sapi_poland){
    FactoryGirl.create(:geo_entity, iso_code2: 'PL')
  }

  let(:aru){
    aru = FactoryGirl.create(:annual_report_upload, trading_country: sapi_poland)
    aru.sandbox.send(:create_target_table)
    aru
  }

  let(:sandbox_klass) {
    aru.sandbox.ar_klass
  }

  describe :matching_records_for_aru_and_error do
    let(:validation_rule) {
      create_exporter_importer_validation
    }
    before(:each) do
      @shipment1 = sandbox_klass.create(
        trading_partner: 'IT' 
      )
      @shipment2 = sandbox_klass.create(
        trading_partner: sapi_poland.iso_code2
      )
      @validation_error = FactoryGirl.create(
        :validation_error,
        annual_report_upload_id: aru.id,
        validation_rule_id: validation_rule.id,
        matching_criteria: {
          importer: sapi_poland.iso_code2, exporter: sapi_poland.iso_code2
        }
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
