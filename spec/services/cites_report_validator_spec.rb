require "rails_helper"

RSpec.describe CitesReportValidator do

  describe :call do
    context 'when CITES Report not found' do
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
        it "sends an email" do
          expect { CitesReportValidator.call(aru.id)[:CITESReportResult][:Status] }.to(
            change { ActionMailer::Base.deliveries.count }.by(1)
          )
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
        it "sends an email" do
          expect { CitesReportValidator.call(aru.id)[:CITESReportResult][:Status] }.to(
            change { ActionMailer::Base.deliveries.count }.by(1)
          )
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

  describe :generate_validation_report do
    let(:aru){ FactoryGirl.create(:annual_report_upload) }
    let(:shipment){
      sandbox = aru.sandbox
      sandbox.copy_data({
        CITESReport: [
          {
            CITESReportRow:  {
              TradingPartnerId:  "FR",
              Year:  2016,
              ScientificName:  "Alligator mississipiensis",
              Appendix:  nil,
              TermCode:  "SKI",
              Quantity:  5.0,
              UnitCode:  "KIL",
              SourceCode:  "W",
              PurposeCode:  "Z",
              OriginCountryId:  "US",
              OriginPermitId:  nil,
              ExportPermitId:  "CH123",
              ImportPermitId:  nil
            }
          }
        ]
      })
      sandbox.ar_klass.first
    }
    let(:validation_rule){
      FactoryGirl.create(:validation_rule, is_primary: true)
    }
    let(:validation_error){
      FactoryGirl.create(
        :validation_error,
        annual_report_upload: aru,
        validation_rule: validation_rule,
        error_message: 'XXX',
        error_count: 1
      )
    }
    before(:each) do
      allow(aru).to(
        receive_message_chain(:persisted_validation_errors).and_return(
          [validation_error]
        )
      )
      allow(validation_rule).to(
        receive(:matching_records_for_aru_and_error).and_return(
          [shipment]
        )
      )
    end
    it "should return a validation report structure" do
      expect(
        CitesReportValidator.generate_validation_report(aru)
      ).to eq(
        {0 => {data: shipment.attributes, errors: ['XXX']}}
      )
    end
  end
end
