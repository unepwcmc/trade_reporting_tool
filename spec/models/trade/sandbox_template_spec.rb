require "rails_helper"

RSpec.describe Trade::SandboxTemplate, type: :model do
  let(:sandbox_template) {
    FactoryGirl.create(:sandbox_template, year: '2016')
  }

  describe :create do
    it "generates a version with create event", versioning: true do
      expect(sandbox_template.versions.size).to eq(1)
      expect(sandbox_template.versions.last.event).to eq('create')
    end
  end

  describe :update do
    it "generates a version with update", versioning: true do
      sandbox_template.update_attributes(year: '2015')

      expect(sandbox_template.versions.size).to eq(2)
      expect(sandbox_template.versions.last.event).to eq('update')
    end
  end
end
