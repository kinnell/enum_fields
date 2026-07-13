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

  describe "Handling :scopeable option" do
    context "when false" do
      before { TestModel.enum_field :status, definitions, scopeable: false }

      let(:scope_calls) do
        definitions.keys.map { |key| -> { TestModel.public_send("#{key}_status") } }
      end

      it "does not define scope methods" do
        expect(scope_calls).to all(raise_error(NoMethodError))
      end
    end

    context "when true (default)" do
      before { TestModel.enum_field :status, definitions }

      let(:scope_queries) do
        definitions.map do |key, metadata|
          [TestModel.public_send("#{key}_status").to_sql, metadata[:value]]
        end
      end

      it "defines a scope for each definition" do
        expect(scope_queries).to all(satisfy { |sql, value| sql.include?("\"status\" = '#{value}'") })
      end
    end
  end

  describe "Handling :validatable option" do
    context "when false" do
      before { TestModel.enum_field :status, definitions, validatable: false }

      let(:record) { TestModel.new(status: "anything") }

      before { record.valid? }

      it "allows any value" do
        expect(record).to be_valid
      end

      it "does not add an error on the accessor" do
        expect(record.errors[:status]).to be_empty
      end
    end

    context "when true (default)" do
      before { TestModel.enum_field :status, definitions }

      context "with an invalid value" do
        let(:record) { TestModel.new(status: "archived") }

        before { record.valid? }

        it "is invalid" do
          expect(record).to be_invalid
        end

        it "adds an error on the accessor" do
          expect(record.errors[:status]).not_to be_empty
        end
      end

      context "with a valid value" do
        let(:record) { TestModel.new(status: definitions.values.first[:value]) }

        before { record.valid? }

        it "is valid" do
          expect(record).to be_valid
        end

        it "does not add an error on the accessor" do
          expect(record.errors[:status]).to be_empty
        end
      end

      context "with a nil value" do
        let(:record) { TestModel.new(status: nil) }

        before { record.valid? }

        it "is valid" do
          expect(record).to be_valid
        end

        it "does not add an error on the accessor" do
          expect(record.errors[:status]).to be_empty
        end
      end
    end
  end

  describe "Handling :nullable option" do
    context "when false" do
      before { TestModel.enum_field :status, definitions, nullable: false }

      context "with a nil value" do
        let(:record) { TestModel.new(status: nil) }

        before { record.valid? }

        it "is invalid" do
          expect(record).to be_invalid
        end

        it "adds an error on the accessor" do
          expect(record.errors[:status]).not_to be_empty
        end
      end

      context "with a valid value" do
        let(:record) { TestModel.new(status: definitions.values.first[:value]) }

        before { record.valid? }

        it "is valid" do
          expect(record).to be_valid
        end

        it "does not add an error on the accessor" do
          expect(record.errors[:status]).to be_empty
        end
      end
    end

    context "when true (default)" do
      before { TestModel.enum_field :status, definitions }

      context "with a nil value" do
        let(:record) { TestModel.new(status: nil) }

        before { record.valid? }

        it "is valid" do
          expect(record).to be_valid
        end

        it "does not add an error on the accessor" do
          expect(record.errors[:status]).to be_empty
        end
      end
    end
  end

  describe "Handling :inquirable option" do
    context "when false" do
      before { TestModel.enum_field :status, definitions, inquirable: false }

      let(:inquiry_calls) do
        definitions.keys.map { |key| -> { record.public_send("#{key}_status?") } }
      end

      it "does not define inquiry methods" do
        expect(inquiry_calls).to all(raise_error(NoMethodError))
      end
    end

    context "when true (default)" do
      before { TestModel.enum_field :status, definitions }

      let(:output) do
        definitions.keys.to_h { |key| [key, record.public_send("#{key}_status?")] }
      end
      let(:expected_output) do
        definitions.transform_values { |metadata| record.status == metadata[:value] }
      end

      it "returns whether the accessor matches each definition" do
        expect(output).to eq(expected_output)
      end
    end
  end
end
