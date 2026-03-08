# frozen_string_literal: true

RSpec.describe EnumFields::Base, "Configuration" do
  include_context "with TestModel"

  let(:definitions) do
    {
      draft: {
        value: "draft",
        label: "Draft",
      },
      published: {
        value: "published",
        label: "Published",
      },
    }
  end

  describe "scope: false" do
    before do
      TestModel.enum_field :status, definitions, scope: false
    end

    it "does not define scope methods" do
      expect(TestModel).not_to respond_to(:draft_status)
      expect(TestModel).not_to respond_to(:published_status)
    end
  end

  describe "scope: true (default)" do
    before do
      TestModel.enum_field :status, definitions
    end

    it "defines scope methods" do
      expect(TestModel).to respond_to(:draft_status)
      expect(TestModel).to respond_to(:published_status)
    end
  end

  describe "validate: false" do
    before do
      TestModel.enum_field :status, definitions, validate: false
    end

    it "does not add validations" do
      expect(TestModel.validations[:status]).to be_nil
    end

    it "allows any value" do
      record = TestModel.new(status: "anything")
      expect(record).to be_valid
    end
  end

  describe "validate: true (default)" do
    before do
      TestModel.enum_field :status, definitions
    end

    it "adds inclusion validation" do
      expect(TestModel.validations[:status]).to be_present
    end

    it "rejects invalid values" do
      record = TestModel.new(status: "archived")
      expect(record).to be_invalid
    end

    it "accepts valid values" do
      record = TestModel.new(status: "draft")
      expect(record).to be_valid
    end

    it "allows nil" do
      record = TestModel.new(status: nil)
      expect(record).to be_valid
    end
  end
end
