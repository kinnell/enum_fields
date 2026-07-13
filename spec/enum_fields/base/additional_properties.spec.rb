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
    let(:output) { TestModel.statuses }

    it "returns definitions as a hash with the additional properties" do
      expect(output).to match(definitions)
    end
  end

  describe "Instance.<accessor>_metadata" do
    let(:output) { record.status_metadata }

    it "returns the metadata of the accessor with the additional properties" do
      expect(output).to match(definitions[:draft])
    end
  end

  describe "Instance.<accessor>_<property>" do
    let(:output) { record.status_description }

    it "returns the value of the additional property" do
      expect(output).to eq(definitions[:draft][:description])
    end
  end
end
