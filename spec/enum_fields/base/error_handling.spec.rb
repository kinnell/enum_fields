# frozen_string_literal: true

RSpec.describe EnumFields::Base, "Error Handling" do
  include_context "with TestModel"

  describe "Model.enum_field" do
    subject(:define_enum_field) { TestModel.enum_field :status, definitions }

    context "when :definitions is nil" do
      let(:definitions) { nil }

      it "raises a MissingDefinitionsError" do
        expect { define_enum_field }.to raise_error(EnumFields::MissingDefinitionsError)
      end
    end

    context "when :definitions is not a Hash, Array, or HashWithIndifferentAccess" do
      let(:definitions) { "invalid" }

      it "raises an InvalidDefinitionsError" do
        expect { define_enum_field }.to raise_error(EnumFields::InvalidDefinitionsError)
      end
    end

    context "when :definitions is missing :value property" do
      let(:definitions) do
        {
          draft: {
            label: "Draft",
          },
          published: {
            label: "Published",
          },
        }
      end

      it "raises an InvalidDefinitionsError" do
        expect { define_enum_field }.to raise_error(EnumFields::InvalidDefinitionsError)
      end
    end
  end
end
