require "rails_helper"

RSpec.describe CitesReportValidator do

  describe :call do
    let(:aru){ FactoryGirl.create(:annual_report_upload) }
    context 'when CITES Report not found' do
      let(:args){ [nil, false] }
      it "should return error" do
        expect(
          CitesReportValidator.call(*args)[:Status]
        ).to eq('ERROR')
      end
    end
    let(:sapi_poland){
      FactoryGirl.create(:geo_entity, iso_code2: 'PL')
    }
    let(:epix_user){
      FactoryGirl.create(:epix_user)
    }
    context 'when force_submit' do
      let(:args){ [aru.id, true] }
    
      context 'when no secondary errors' do
        before(:each) do
          allow_any_instance_of(Trade::AnnualReportUpload).to(
            receive(:primary_validation_errors).and_return([])
          )
          allow_any_instance_of(Trade::AnnualReportUpload).to(
            receive(:secondary_validation_errors).and_return([])
          )
        end
        it "should return success" do
          expect(
            CitesReportValidator.call(*args)[:Status]
          ).to eq('SUCCESS')
        end
      end

      context 'when secondary errors' do
        before(:each) do
          allow_any_instance_of(Trade::AnnualReportUpload).to(
            receive(:primary_validation_errors).and_return([])
          )
          allow_any_instance_of(Trade::AnnualReportUpload).to(
            receive(:secondary_validation_errors).and_return([Trade::ValidationError.new])
          )
        end
        it "should return success" do
          expect(
            CitesReportValidator.call(*args)[:Status]
          ).to eq('SUCCESS')
        end
      end

      context 'when primary errors' do
        before(:each) do
          allow_any_instance_of(Trade::AnnualReportUpload).to(
            receive(:primary_validation_errors).and_return([Trade::ValidationError.new])
          )
        end
        it "should return error" do
          expect(
            CitesReportValidator.call(*args)[:Status]
          ).to eq('ERROR')
        end
      end
    end

    context 'when no force_submit' do
      let(:args){ [aru.id, false] }
    
      context 'when no secondary errors' do
        before(:each) do
          allow_any_instance_of(Trade::AnnualReportUpload).to(
            receive(:primary_validation_errors).and_return([])
          )
          allow_any_instance_of(Trade::AnnualReportUpload).to(
            receive(:secondary_validation_errors).and_return([])
          )
        end
        it "should return success" do
          expect(
            CitesReportValidator.call(*args)[:Status]
          ).to eq('SUCCESS')
        end
      end

      context 'when secondary errors' do
        before(:each) do
          allow_any_instance_of(Trade::AnnualReportUpload).to(
            receive(:primary_validation_errors).and_return([])
          )
          allow_any_instance_of(Trade::AnnualReportUpload).to(
            receive(:secondary_validation_errors).and_return([Trade::ValidationError.new])
          )
        end
        it "should return error" do
          expect(
            CitesReportValidator.call(*args)[:Status]
          ).to eq('ERROR')
        end
      end

      context 'when primary errors' do
        before(:each) do
          allow_any_instance_of(Trade::AnnualReportUpload).to(
            receive(:primary_validation_errors).and_return([Trade::ValidationError.new])
          )
        end
        it "should return error" do
          expect(
            CitesReportValidator.call(*args)[:Status]
          ).to eq('ERROR')
        end
      end
    end
  end
end
