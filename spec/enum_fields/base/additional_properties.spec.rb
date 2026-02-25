# frozen_string_literal: true

RSpec.describe EnumFields::Base, "Additional Properties" do
  include_context "with TestModel"

  let(:definitions) do
    {
      draft: {
        value: "draft",
        label: "Draft",
        description: "Content is being worked on",
      },
      published: {
        value: "published",
        label: "Published",
        description: "Content is live",
      },
    }
  end

  before do
    TestModel.enum_field :status, definitions
  end

  describe "Model.<accessor>s" do
    it "returns definitions as a hash with the additional properties" do
      expect(TestModel.statuses).to match(definitions)
    end
  end

  describe "Instance.<accessor>_metadata" do
    it "returns the metadata of the accessor with the additional properties" do
      expect(record.status_metadata).to match(definitions[:draft])
    end
  end

  describe "Instance.<accessor>_<property>" do
    it "returns the value of the additional property" do
      expect(record.status_description).to eq(definitions[:draft][:description])
    end
  end
end
