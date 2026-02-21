# frozen_string_literal: true

RSpec.describe EnumFields::Base, "Error Handling" do
  include_context "with TestModel"

  context "when :definitions is nil" do
    let(:definitions) { nil }

    it "raises an error" do
      expect do
        TestModel.enum_field :sample_column, definitions
      end.to raise_error(EnumFields::MissingDefinitionsError)
    end
  end

  context "when :definitions is not a Hash, Array, or HashWithIndifferentAccess" do
    let(:definitions) { "invalid" }

    it "raises an error" do
      expect do
        TestModel.enum_field :sample_column, definitions
      end.to raise_error(EnumFields::InvalidDefinitionsError)
    end
  end

  context "when :definitions is missing :value property" do
    let(:definitions) do
      {
        value1: {
          label: "value1",
        },
        value2: {
          label: "value2",
        },
      }
    end

    it "raises an error" do
      expect do
        TestModel.enum_field :sample_column, definitions
      end.to raise_error(EnumFields::InvalidDefinitionsError)
    end
  end
end
