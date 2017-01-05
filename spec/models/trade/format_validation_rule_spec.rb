require "rails_helper"

RSpec.describe Trade::FormatValidationRule, type: :model do

  include_context :validation_rules_helpers

  let(:aru){
    aru = FactoryGirl.create(:annual_report_upload)
    aru.sandbox.send(:create_target_table)
    aru
  }

  let(:sandbox_klass) {
    aru.sandbox.ar_klass
  }

  describe :matching_records_for_aru_and_error do
    let(:validation_rule) {
      create_year_format_validation
    }
    before(:each) do
      @shipment1 = sandbox_klass.create(
        year: 2016
      )
      @shipment2 = sandbox_klass.create(
        year: 'xxxx'
      )
      @validation_error = FactoryGirl.create(
        :validation_error,
        annual_report_upload_id: aru.id,
        validation_rule_id: validation_rule.id
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
