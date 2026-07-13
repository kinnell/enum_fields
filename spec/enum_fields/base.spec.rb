# frozen_string_literal: true

RSpec.describe EnumFields::Base do
  include_context "with TestModel"

  let(:definitions) do
    {
      draft: {
        value: "draft",
        label: "Draft",
        icon: "pencil",
        color: "gray",
        tooltip: "Not yet published",
      },
      published: {
        value: "published",
        label: "Published",
        icon: "check",
        color: "green",
        tooltip: "Publicly visible",
      },
    }
  end

  let(:category_definitions) do
    {
      blog: {
        value: "blog",
        label: "Blog",
      },
      tutorial: {
        value: "tutorial",
        label: "Tutorial",
      },
    }
  end
  let(:current_metadata) { definitions.values.find { |metadata| metadata[:value] == record.status } }

  before do
    TestModel.enum_field :status, definitions
    TestModel.enum_field :category, category_definitions
  end

  describe "Model.enum_field_for" do
    context "when :accessor is defined" do
      let(:output) { TestModel.enum_field_for(:status) }

      it "returns the definition" do
        expect(output).to match(definitions)
      end
    end

    context "when :accessor is not defined" do
      let(:output) { TestModel.enum_field_for(:priority) }

      it "returns nil" do
        expect(output).to be_nil
      end
    end
  end

  describe "Model.enum_field?" do
    context "when :accessor is defined" do
      let(:output) { TestModel.enum_field?(:status) }

      it "returns true" do
        expect(output).to be true
      end
    end

    context "when :accessor is not defined" do
      let(:output) { TestModel.enum_field?(:priority) }

      it "returns false" do
        expect(output).to be false
      end
    end
  end

  describe "Model.<accessor>s" do
    let(:output) { TestModel.statuses }

    it "returns definitions as a hash" do
      expect(output).to match(definitions)
    end
  end

  describe "Model.<accessor>s_count" do
    let(:output) { TestModel.statuses_count }

    it "returns the number of definitions" do
      expect(output).to eq(definitions.size)
    end
  end

  describe "Model.<accessor>_values" do
    let(:output) { TestModel.status_values }

    it "returns the values of the definitions" do
      expect(output).to match_array(definitions.values.pluck(:value))
    end
  end

  describe "Model.<accessor>_options" do
    let(:output) { TestModel.status_options }

    it "returns the options of the definitions" do
      expect(output).to match(definitions.map { |_key, definition|
        [definition[:label], definition[:value]]
      })
    end
  end

  describe "Model.<key>_<accessor>_value" do
    let(:output) do
      definitions.keys.to_h { |key| [key, TestModel.public_send("#{key}_status_value")] }
    end
    let(:expected_output) { definitions.transform_values { |metadata| metadata[:value] } }

    it "returns the value for each definition" do
      expect(output).to eq(expected_output)
    end
  end

  describe "Instance.enum_fields_metadata" do
    let(:output) { record.enum_fields_metadata }

    it "returns a HashWithIndifferentAccess" do
      expect(output).to be_a(HashWithIndifferentAccess)
    end

    it "returns the metadata of the accessor" do
      expect(output).to match({
        status: definitions[record.status.to_sym],
        category: category_definitions[record.category.to_sym],
      })
    end
  end

  describe "Instance.<accessor>" do
    let(:output) { record.status }

    it "returns the value of the accessor" do
      expect(output).to eq(status_value)
    end
  end

  describe "Instance.<accessor>=" do
    let(:new_value) { definitions.values.last[:value] }

    before { record.status = new_value }

    it "sets the value of the accessor" do
      expect(record.status).to eq(new_value)
    end
  end

  describe "Instance.<accessor>_metadata" do
    let(:output) { record.status_metadata }

    it "returns the metadata of the accessor" do
      expect(output).to match(current_metadata)
    end
  end

  describe "Instance.<accessor>_value" do
    let(:output) { record.status_value }

    it "returns the value of the accessor" do
      expect(output).to eq(current_metadata[:value])
    end
  end

  describe "Instance.<accessor>_<property>" do
    let(:properties) { current_metadata.except(:value) }
    let(:output) do
      properties.keys.to_h { |property| [property, record.public_send("status_#{property}")] }
    end

    it "returns each additional property of the accessor" do
      expect(output).to eq(properties)
    end
  end

  describe "Instance.<key>_<accessor>?" do
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

  describe "Model.<key>_<accessor>" do
    let(:scope_queries) do
      definitions.map do |key, metadata|
        [TestModel.public_send("#{key}_status").to_sql, metadata[:value]]
      end
    end

    it "filters by the value for each definition" do
      expect(scope_queries).to all(satisfy { |sql, value| sql.include?("\"status\" = '#{value}'") })
    end
  end

  describe "Validating Instance.<accessor>" do
    context "when the Instance.<accessor> value is in the list of definitions" do
      let(:status_value) { "draft" }

      before { record.valid? }

      it "is valid" do
        expect(record).to be_valid
      end

      it "does not add an error on the accessor" do
        expect(record.errors[:status]).to be_empty
      end
    end

    context "when the Instance.<accessor> value is not in the list of definitions" do
      let(:status_value) { "archived" }

      before { record.valid? }

      it "is not valid" do
        expect(record).to be_invalid
      end

      it "adds an error on the accessor" do
        expect(record.errors[:status]).not_to be_empty
      end
    end
  end
end
