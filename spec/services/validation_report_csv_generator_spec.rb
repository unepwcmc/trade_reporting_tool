require "rails_helper"

RSpec.describe ValidationReportCsvGenerator do

  describe :call do

    let(:validation_report){
      {
        "0" => {
          "data" => {
            "id" => 4413062,
            "year" => "2016",
            "appendix" => nil,
            "quantity" => "5.0",
            "term_code" => "SKI",
            "unit_code" => "KIL",
            "created_at" => "2016-11-25T11:28:16.197Z",
            "taxon_name" => "Alligator mississipiensis",
            "updated_at" => "2016-11-25T11:28:16.197Z",
            "source_code" => "W",
            "purpose_code" => "Z",
            "export_permit" => "CH123",
            "import_permit" => nil,
            "origin_permit" => nil,
            "trading_partner" => "FR",
            "taxon_concept_id" => 6810,
            "country_of_origin" => "US",
            "reported_taxon_concept_id" => 34861
          },
          "errors" => [
            "appendix cannot be blank"
          ]
        },
        "1" => {
          "data" => {
            "id" => 4413063,
            "year" => "2016",
            "appendix" => "II",
            "quantity" => "5.0",
            "term_code" => "SKI",
            "unit_code" => "KIL",
            "created_at" => "2016-11-25T11:28:16.197Z",
            "taxon_name" => "Caiman latirostris",
            "updated_at" => "2016-11-25T11:28:16.197Z",
            "source_code" => "W",
            "purpose_code" => "Z",
            "export_permit" => "CH123",
            "import_permit" => nil,
            "origin_permit" => nil,
            "trading_partner" => "FR",
            "taxon_concept_id" => 5390,
            "country_of_origin" => "US",
            "reported_taxon_concept_id" => 5390
          },
          "errors" => nil
        }
      }
    }

    before(:each) do
      tempfile = ValidationReportCsvGenerator.call(aru)
      @csv_data = CSV.open(tempfile.path, 'r', headers: true).read
    end

    context "when reported by exporter" do
      let(:aru){
        FactoryGirl.create(
          :annual_report_upload,
          point_of_view: 'E',
          validation_report: validation_report,
          validated_at: Time.now
        )
      }
      it "should have exporter columns" do
        expect(@csv_data.headers).to eq(Trade::SandboxTemplate::EXPORTER_COLUMNS + ['ERRORS'])
      end
      it "should have 3 rows" do
        expect(@csv_data.size).to eq(2)
      end
    end
    context "when reported by importer" do
      let(:aru){
        FactoryGirl.create(
          :annual_report_upload,
          point_of_view: 'I',
          validation_report: validation_report
        )
      }
      it "should have exporter columns" do
        expect(@csv_data.headers).to eq(Trade::SandboxTemplate::IMPORTER_COLUMNS + ['ERRORS'])
      end
      it "should have 3 rows" do
        expect(@csv_data.size).to eq(2)
      end
    end      
  end

end
