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

  describe "scopeable: false" do
    before do
      TestModel.enum_field :status, definitions, scopeable: false
    end

    it "does not define scope methods" do
      expect(TestModel).not_to respond_to(:draft_status)
      expect(TestModel).not_to respond_to(:published_status)
    end
  end

  describe "scopeable: true (default)" do
    before do
      TestModel.enum_field :status, definitions
    end

    it "defines scope methods" do
      expect(TestModel).to respond_to(:draft_status)
      expect(TestModel).to respond_to(:published_status)
    end
  end

  describe "validatable: false" do
    before do
      TestModel.enum_field :status, definitions, validatable: false
    end

    it "does not add validations" do
      expect(TestModel.validations[:status]).to be_nil
    end

    it "allows any value" do
      record = TestModel.new(status: "anything")
      expect(record).to be_valid
    end
  end

  describe "validatable: true (default)" do
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

  describe "nullable: false" do
    before do
      TestModel.enum_field :status, definitions, nullable: false
    end

    it "rejects nil values" do
      record = TestModel.new(status: nil)
      expect(record).to be_invalid
    end

    it "accepts valid values" do
      record = TestModel.new(status: "draft")
      expect(record).to be_valid
    end
  end

  describe "nullable: true (default)" do
    before do
      TestModel.enum_field :status, definitions
    end

    it "allows nil values" do
      record = TestModel.new(status: nil)
      expect(record).to be_valid
    end
  end

  describe "inquirable: false" do
    before do
      TestModel.enum_field :status, definitions, inquirable: false
    end

    it "does not define inquiry methods" do
      expect(TestModel.method_defined?(:draft_status?)).to be false
      expect(TestModel.method_defined?(:published_status?)).to be false
    end
  end

  describe "inquirable: true (default)" do
    before do
      TestModel.enum_field :status, definitions
    end

    it "defines inquiry methods" do
      expect(TestModel.method_defined?(:draft_status?)).to be true
      expect(TestModel.method_defined?(:published_status?)).to be true
    end
  end
end
