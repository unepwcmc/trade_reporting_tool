require "rails_helper"

RSpec.describe CitesReportValidator do

  describe :call do
    context 'when CITES Report not found' do
      let(:args){ [nil, false] }
      it "should return error" do
        expect(
          CitesReportValidator.call(nil)[:CITESReportResult][:Status]
        ).to eq('UPLOAD_FAILED')
      end
    end
    let(:sapi_poland){
      FactoryGirl.create(:geo_entity, iso_code2: 'PL')
    }
    let(:epix_user){
      FactoryGirl.create(:epix_user)
    }
    before(:each) do
      allow(CitesReportValidator).to(receive(:generate_validation_report).and_return({}))
    end
    context 'when force_submit' do
      let(:aru){
        FactoryGirl.create(:annual_report_upload, force_submit: true)
      }
      context 'when no secondary errors' do
        before(:each) do
          allow_any_instance_of(Trade::AnnualReportUpload).to(
            receive_message_chain(:persisted_validation_errors, :primary).and_return([])
          )
          allow_any_instance_of(Trade::AnnualReportUpload).to(
            receive_message_chain(:persisted_validation_errors, :secondary).and_return([])
          )
        end
        it "should return success" do
          expect(
            CitesReportValidator.call(aru.id)[:CITESReportResult][:Status]
          ).to eq('PENDING')
        end
      end

      context 'when secondary errors' do
        before(:each) do
          allow_any_instance_of(Trade::AnnualReportUpload).to(
            receive_message_chain(:persisted_validation_errors, :primary).and_return([])
          )
          allow_any_instance_of(Trade::AnnualReportUpload).to(
            receive_message_chain(:persisted_validation_errors, :secondary).and_return([Trade::ValidationError.new])
          )
        end
        it "should return success" do
          expect(
            CitesReportValidator.call(aru.id)[:CITESReportResult][:Status]
          ).to eq('PENDING')
        end
      end

      context 'when primary errors' do
        before(:each) do
          allow_any_instance_of(Trade::AnnualReportUpload).to(
            receive_message_chain(:persisted_validation_errors, :primary).and_return([Trade::ValidationError.new])
          )
          allow_any_instance_of(Trade::AnnualReportUpload).to(
            receive_message_chain(:persisted_validation_errors, :secondary).and_return([])
          )
        end
        it "should return error" do
          expect(
            CitesReportValidator.call(aru.id)[:CITESReportResult][:Status]
          ).to eq('VALIDATION_FAILED')
        end
      end
    end

    context 'when no force_submit' do
      let(:aru){
        FactoryGirl.create(:annual_report_upload)
      }
    
      context 'when no secondary errors' do
        before(:each) do
          allow_any_instance_of(Trade::AnnualReportUpload).to(
            receive_message_chain(:persisted_validation_errors, :primary).and_return([])
          )
          allow_any_instance_of(Trade::AnnualReportUpload).to(
            receive_message_chain(:persisted_validation_errors, :secondary).and_return([])
          )
        end
        it "should return success" do
          expect(
            CitesReportValidator.call(aru.id)[:CITESReportResult][:Status]
          ).to eq('PENDING')
        end
      end

      context 'when secondary errors' do
        before(:each) do
          allow_any_instance_of(Trade::AnnualReportUpload).to(
            receive_message_chain(:persisted_validation_errors, :primary).and_return([])
          )
          allow_any_instance_of(Trade::AnnualReportUpload).to(
            receive_message_chain(:persisted_validation_errors, :secondary).and_return([Trade::ValidationError.new])
          )
        end
        it "should return error" do
          expect(
            CitesReportValidator.call(aru.id)[:CITESReportResult][:Status]
          ).to eq('VALIDATION_FAILED')
        end
      end

      context 'when primary errors' do
        before(:each) do
          allow_any_instance_of(Trade::AnnualReportUpload).to(
            receive_message_chain(:persisted_validation_errors, :primary).and_return([Trade::ValidationError.new])
          )
          allow_any_instance_of(Trade::AnnualReportUpload).to(
            receive_message_chain(:persisted_validation_errors, :secondary).and_return([])
          )
        end
        it "should return error" do
          expect(
            CitesReportValidator.call(aru.id)[:CITESReportResult][:Status]
          ).to eq('VALIDATION_FAILED')
        end
      end
    end
  end
end
