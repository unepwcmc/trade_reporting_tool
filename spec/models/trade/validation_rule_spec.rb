require "rails_helper"

RSpec.describe Trade::ValidationRule, type: :model do

  include_context :validation_rules_helpers

  let(:aru){
    aru = FactoryGirl.create(:annual_report_upload)
    aru.sandbox.send(:create_target_table)
    aru
  }

  let(:sandbox_klass) {
    aru.sandbox.ar_klass
  }

  describe :refresh_errors_if_needed do
    let(:validation_rule) {
      create_taxon_name_presence_validation
    }
    before(:each) do
      @shipment1 = sandbox_klass.create(
        taxon_name: 'Canis lupus'
      )
      @shipment2 = sandbox_klass.create(
        taxon_name: ''
      )
      @shipment3 = sandbox_klass.create(
        taxon_name: nil
      )
      @validation_error = FactoryGirl.create(
        :validation_error,
        annual_report_upload_id: aru.id,
        validation_rule_id: validation_rule.id,
        matching_criteria: "{}",
        is_ignored: false,
        is_primary: true,
        error_message: "taxon_name cannot be blank",
        error_count: 2
      )
    end

    context "when no updates" do
      specify do
        expect {
          validation_rule.refresh_errors_if_needed(aru)
        }.not_to change { Trade::ValidationError.count }
      end
    end

    context "when updates and error fixed for all records" do
      specify "error record is destroyed" do
        Timecop.travel(Time.now + 1)
        @shipment2.update_attributes(taxon_name: 'Canis lupus')
        @shipment3.update_attributes(taxon_name: 'Canis lupus')
        expect {
          validation_rule.refresh_errors_if_needed(aru)
        }.to change { Trade::ValidationError.count }.by(-1)
      end
    end

    context "when updates and error fixed for some records" do
      specify "error record is updated to reflect new error_count" do
        Timecop.travel(Time.now + 1)
        @shipment2.update_attributes(taxon_name: 'Canis lupus')
        expect {
          validation_rule.refresh_errors_if_needed(aru)
        }.to change { @validation_error.reload.error_count }.by(-1)
      end
    end

  end

end
