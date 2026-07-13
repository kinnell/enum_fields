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

  describe "Applying global configuration to Model.enum_field" do
    context "when global :scopeable is false" do
      before do
        EnumFields.configure { |config| config.scopeable = false }
        TestModel.enum_field :status, definitions
      end

      let(:scope_calls) do
        definitions.keys.map { |key| -> { TestModel.public_send("#{key}_status") } }
      end

      it "does not define scope methods" do
        expect(scope_calls).to all(raise_error(NoMethodError))
      end
    end

    context "when global :validatable is false" do
      before do
        EnumFields.configure { |config| config.validatable = false }
        TestModel.enum_field :status, definitions
      end

      let(:record) { TestModel.new(status: "anything") }

      before { record.valid? }

      it "allows any value" do
        expect(record).to be_valid
      end

      it "does not add an error on the accessor" do
        expect(record.errors[:status]).to be_empty
      end
    end

    context "when global :nullable is false" do
      before do
        EnumFields.configure { |config| config.nullable = false }
        TestModel.enum_field :status, definitions
      end

      let(:record) { TestModel.new(status: nil) }

      before { record.valid? }

      it "rejects nil values" do
        expect(record).to be_invalid
      end

      it "adds an error on the accessor" do
        expect(record.errors[:status]).not_to be_empty
      end
    end

    context "when global :inquirable is false" do
      before do
        EnumFields.configure { |config| config.inquirable = false }
        TestModel.enum_field :status, definitions
      end

      let(:inquiry_calls) do
        definitions.keys.map { |key| -> { record.public_send("#{key}_status?") } }
      end

      it "does not define inquiry methods" do
        expect(inquiry_calls).to all(raise_error(NoMethodError))
      end
    end
  end

  describe "Applying per-field options over global configuration" do
    context "when global :scopeable is false but field :scopeable is true" do
      before do
        EnumFields.configure { |config| config.scopeable = false }
        TestModel.enum_field :status, definitions, scopeable: true
      end

      let(:scope_queries) do
        definitions.map do |key, metadata|
          [TestModel.public_send("#{key}_status").to_sql, metadata[:value]]
        end
      end

      it "defines a scope for each definition" do
        expect(scope_queries).to all(satisfy { |sql, value| sql.include?("\"status\" = '#{value}'") })
      end
    end

    context "when global :scopeable is true but field :scopeable is false" do
      before do
        EnumFields.configure { |config| config.scopeable = true }
        TestModel.enum_field :status, definitions, scopeable: false
      end

      let(:scope_calls) do
        definitions.keys.map { |key| -> { TestModel.public_send("#{key}_status") } }
      end

      it "does not define scope methods" do
        expect(scope_calls).to all(raise_error(NoMethodError))
      end
    end

    context "when global :validatable is false but field :validatable is true" do
      before do
        EnumFields.configure { |config| config.validatable = false }
        TestModel.enum_field :status, definitions, validatable: true
      end

      let(:record) { TestModel.new(status: "archived") }

      before { record.valid? }

      it "rejects invalid values" do
        expect(record).to be_invalid
      end

      it "adds an error on the accessor" do
        expect(record.errors[:status]).not_to be_empty
      end
    end

    context "when global :validatable is true but field :validatable is false" do
      before do
        EnumFields.configure { |config| config.validatable = true }
        TestModel.enum_field :status, definitions, validatable: false
      end

      let(:record) { TestModel.new(status: "archived") }

      before { record.valid? }

      it "allows values outside the definitions" do
        expect(record).to be_valid
      end

      it "does not add an error on the accessor" do
        expect(record.errors[:status]).to be_empty
      end
    end

    context "when global :nullable is false but field :nullable is true" do
      before do
        EnumFields.configure { |config| config.nullable = false }
        TestModel.enum_field :status, definitions, nullable: true
      end

      let(:record) { TestModel.new(status: nil) }

      before { record.valid? }

      it "allows nil values" do
        expect(record).to be_valid
      end

      it "does not add an error on the accessor" do
        expect(record.errors[:status]).to be_empty
      end
    end

    context "when global :nullable is true but field :nullable is false" do
      before do
        EnumFields.configure { |config| config.nullable = true }
        TestModel.enum_field :status, definitions, nullable: false
      end

      let(:record) { TestModel.new(status: nil) }

      before { record.valid? }

      it "rejects nil values" do
        expect(record).to be_invalid
      end

      it "adds an error on the accessor" do
        expect(record.errors[:status]).not_to be_empty
      end
    end

    context "when global :inquirable is false but field :inquirable is true" do
      before do
        EnumFields.configure { |config| config.inquirable = false }
        TestModel.enum_field :status, definitions, inquirable: true
      end

      let(:output) do
        definitions.keys.to_h { |key| [key, record.public_send("#{key}_status?")] }
      end
      let(:expected_output) do
        definitions.transform_values { |metadata| record.status == metadata[:value] }
      end

      it "defines inquiry methods for each definition" do
        expect(output).to eq(expected_output)
      end
    end

    context "when global :inquirable is true but field :inquirable is false" do
      before do
        EnumFields.configure { |config| config.inquirable = true }
        TestModel.enum_field :status, definitions, inquirable: false
      end

      let(:inquiry_calls) do
        definitions.keys.map { |key| -> { record.public_send("#{key}_status?") } }
      end

      it "does not define inquiry methods" do
        expect(inquiry_calls).to all(raise_error(NoMethodError))
      end
    end
  end
end
