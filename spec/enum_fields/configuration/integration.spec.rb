# frozen_string_literal: true

RSpec.describe EnumFields::Base, "Global Configuration Integration" do
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

  after { EnumFields.reset_configuration! }

  describe "when global :scopeable is false" do
    before do
      EnumFields.configure { |config| config.scopeable = false }
      TestModel.enum_field :status, definitions
    end

    it "does not define scope methods" do
      expect(TestModel).not_to respond_to(:draft_status)
      expect(TestModel).not_to respond_to(:published_status)
    end
  end

  describe "when global :validatable is false" do
    before do
      EnumFields.configure { |config| config.validatable = false }
      TestModel.enum_field :status, definitions
    end

    it "does not add validations" do
      expect(TestModel.validations[:status]).to be_nil
    end

    it "allows any value" do
      record = TestModel.new(status: "anything")
      expect(record).to be_valid
    end
  end

  describe "when global :nullable is false" do
    before do
      EnumFields.configure { |config| config.nullable = false }
      TestModel.enum_field :status, definitions
    end

    it "rejects nil values" do
      record = TestModel.new(status: nil)
      expect(record).to be_invalid
    end
  end

  describe "when global :inquirable is false" do
    before do
      EnumFields.configure { |config| config.inquirable = false }
      TestModel.enum_field :status, definitions
    end

    it "does not define inquiry methods" do
      expect(TestModel.method_defined?(:draft_status?)).to be false
      expect(TestModel.method_defined?(:published_status?)).to be false
    end
  end

  describe "when per-field option overrides global config" do
    context "when global :scopeable is false but field :scopeable is true" do
      before do
        EnumFields.configure { |config| config.scopeable = false }
        TestModel.enum_field :status, definitions, scopeable: true
      end

      it "defines scope methods" do
        expect(TestModel).to respond_to(:draft_status)
        expect(TestModel).to respond_to(:published_status)
      end
    end

    context "when global :scopeable is true but field :scopeable is false" do
      before do
        EnumFields.configure { |config| config.scopeable = true }
        TestModel.enum_field :status, definitions, scopeable: false
      end

      it "does not define scope methods" do
        expect(TestModel).not_to respond_to(:draft_status)
        expect(TestModel).not_to respond_to(:published_status)
      end
    end

    context "when global :validatable is false but field :validatable is true" do
      before do
        EnumFields.configure { |config| config.validatable = false }
        TestModel.enum_field :status, definitions, validatable: true
      end

      it "adds validations" do
        expect(TestModel.validations[:status]).to be_present
      end

      it "rejects invalid values" do
        record = TestModel.new(status: "archived")
        expect(record).to be_invalid
      end
    end

    context "when global :validatable is true but field :validatable is false" do
      before do
        EnumFields.configure { |config| config.validatable = true }
        TestModel.enum_field :status, definitions, validatable: false
      end

      it "does not add validations" do
        expect(TestModel.validations[:status]).to be_nil
      end
    end

    context "when global :nullable is false but field :nullable is true" do
      before do
        EnumFields.configure { |config| config.nullable = false }
        TestModel.enum_field :status, definitions, nullable: true
      end

      it "allows nil values" do
        record = TestModel.new(status: nil)
        expect(record).to be_valid
      end
    end

    context "when global :nullable is true but field :nullable is false" do
      before do
        EnumFields.configure { |config| config.nullable = true }
        TestModel.enum_field :status, definitions, nullable: false
      end

      it "rejects nil values" do
        record = TestModel.new(status: nil)
        expect(record).to be_invalid
      end
    end

    context "when global :inquirable is false but field :inquirable is true" do
      before do
        EnumFields.configure { |config| config.inquirable = false }
        TestModel.enum_field :status, definitions, inquirable: true
      end

      it "defines inquiry methods" do
        expect(TestModel.method_defined?(:draft_status?)).to be true
        expect(TestModel.method_defined?(:published_status?)).to be true
      end
    end

    context "when global :inquirable is true but field :inquirable is false" do
      before do
        EnumFields.configure { |config| config.inquirable = true }
        TestModel.enum_field :status, definitions, inquirable: false
      end

      it "does not define inquiry methods" do
        expect(TestModel.method_defined?(:draft_status?)).to be false
        expect(TestModel.method_defined?(:published_status?)).to be false
      end
    end
  end
end
