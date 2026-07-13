# frozen_string_literal: true

require "spec_helper"

RSpec.describe EnumFields::EnumField do
  include_context "with TestModel"

  let(:definition) do
    {
      pending: {
        value: "pending",
        label: "Pending",
        icon: "clock",
      },
      active: {
        value: "active",
        label: "Active",
        icon: "check",
      },
    }
  end

  let(:expected_definition) { definition.with_indifferent_access }
  let(:current_metadata) { definition.values.first.with_indifferent_access }
  let(:current_value) { current_metadata[:value] }
  let(:alternate_metadata) { definition.values.last.with_indifferent_access }
  let(:alternate_value) { alternate_metadata[:value] }
  let(:definition_arguments) do
    {
      model_class: TestModel,
      accessor: :status,
      definition: definition,
      options: {},
    }
  end

  before do
    described_class.define(**definition_arguments)
  end

  describe "Model.<accessor>s" do
    let(:output) { TestModel.statuses }

    it "returns the definitions" do
      expect(output).to eq(expected_definition)
    end
  end

  describe "Model.<accessor>s_count" do
    let(:output) { TestModel.statuses_count }

    it "returns the number of definitions" do
      expect(output).to eq(definition.size)
    end
  end

  describe "Model.<accessor>_values" do
    let(:output) { TestModel.status_values }

    it "returns the definition values" do
      expect(output).to match_array(definition.values.pluck(:value))
    end
  end

  describe "Model.<accessor>_options" do
    let(:output) { TestModel.status_options }
    let(:expected_options) { definition.values.map { |metadata| [metadata[:label], metadata[:value]] } }

    it "returns label and value pairs" do
      expect(output).to eq(expected_options)
    end

    context "when :definition keys differ from their values" do
      let(:definition) do
        {
          pending_review: {
            value: "in review",
            label: "Pending Review",
          },
          active: {
            value: "is active",
            label: "Active",
          },
        }
      end

      it "returns the stored values" do
        expect(output).to eq(expected_options)
      end
    end
  end

  describe "Model.<key>_<accessor>_value" do
    let(:output) do
      definition.keys.to_h { |key| [key, TestModel.public_send("#{key}_status_value")] }
    end
    let(:expected_output) { definition.transform_values { |metadata| metadata[:value] } }

    it "returns the value for each definition" do
      expect(output).to eq(expected_output)
    end
  end

  describe "Instance.<accessor>_metadata" do
    let(:record) { TestModel.new(status: current_value) }
    let(:output) { record.status_metadata }

    it "returns the metadata for the current accessor value" do
      expect(output).to eq(current_metadata)
    end

    context "when the accessor value is nil" do
      let(:record) { TestModel.new(status: nil) }

      it "returns nil" do
        expect(output).to be_nil
      end
    end
  end

  describe "Instance.<accessor>_value" do
    let(:record) { TestModel.new(status: current_value) }
    let(:output) { record.status_value }

    it "returns the current accessor value" do
      expect(output).to eq(current_metadata[:value])
    end
  end

  describe "Instance.<accessor>_label" do
    let(:record) { TestModel.new(status: current_value) }
    let(:output) { record.status_label }

    it "returns the label for the current accessor value" do
      expect(output).to eq(current_metadata[:label])
    end
  end

  describe "Instance.<accessor>_icon" do
    let(:record) { TestModel.new(status: current_value) }
    let(:output) { record.status_icon }

    it "returns the icon for the current accessor value" do
      expect(output).to eq(current_metadata[:icon])
    end
  end

  describe "Instance.<key>_<accessor>?" do
    let(:record) { TestModel.new(status: current_value) }
    let(:output) do
      definition.keys.to_h { |key| [key, record.public_send("#{key}_status?")] }
    end
    let(:expected_output) do
      definition.transform_values { |metadata| record.status == metadata[:value] }
    end

    it "returns whether the accessor matches each definition" do
      expect(output).to eq(expected_output)
    end
  end

  describe "Model.<key>_<accessor>" do
    let(:scope_queries) do
      definition.map do |key, metadata|
        [TestModel.public_send("#{key}_status").to_sql, metadata[:value]]
      end
    end

    it "filters by the value for each definition" do
      expect(scope_queries).to all(satisfy { |sql, value| sql.include?("\"status\" = '#{value}'") })
    end
  end

  describe "Validating Instance.<accessor>" do
    let(:record) { TestModel.new(status: accessor_value) }

    context "when the accessor is not a definition value" do
      let(:accessor_value) { "invalid" }

      before { record.valid? }

      it "is invalid" do
        expect(record).to be_invalid
      end

      it "adds an error on the accessor" do
        expect(record.errors[:status]).to include("is not included in the list")
      end
    end

    context "when the accessor is a definition value" do
      let(:accessor_value) { current_value }

      before { record.valid? }

      it "is valid" do
        expect(record).to be_valid
      end

      it "does not add an error on the accessor" do
        expect(record.errors[:status]).to be_empty
      end
    end

    context "when the accessor is nil" do
      let(:accessor_value) { nil }

      before { record.valid? }

      it "is valid" do
        expect(record).to be_valid
      end

      it "does not add an error on the accessor" do
        expect(record.errors[:status]).to be_empty
      end
    end
  end

  describe "Handling :column option" do
    let(:column_definition_arguments) do
      {
        model_class: TestModel,
        accessor: :workflow,
        definition: definition,
        options: { column: :status },
      }
    end
    let(:record) { TestModel.new(status: current_value) }

    before do
      described_class.define(**column_definition_arguments)
    end

    describe "Instance.<accessor>" do
      let(:output) { record.workflow }

      it "returns the configured column value" do
        expect(output).to eq(current_value)
      end
    end

    describe "Instance.<accessor>=" do
      before do
        record.workflow = alternate_value
      end

      it "sets the configured column" do
        expect(record.status).to eq(alternate_value)
      end
    end

    describe "Instance.<accessor>_metadata" do
      let(:output) { record.workflow_metadata }

      it "returns metadata for the configured column value" do
        expect(output).to eq(current_metadata)
      end
    end

    describe "Instance.<accessor>_<property>" do
      let(:output) { record.workflow_label }

      it "returns the property for the configured column value" do
        expect(output).to eq(current_metadata[:label])
      end
    end

    describe "Instance.<key>_<accessor>?" do
      let(:output) do
        definition.keys.to_h { |key| [key, record.public_send("#{key}_workflow?")] }
      end
      let(:expected_output) do
        definition.transform_values { |metadata| record.status == metadata[:value] }
      end

      it "returns whether the configured column matches each definition" do
        expect(output).to eq(expected_output)
      end
    end

    describe "Model.<key>_<accessor>" do
      let(:scope_queries) do
        definition.map do |key, metadata|
          [TestModel.public_send("#{key}_workflow").to_sql, metadata[:value]]
        end
      end

      it "filters the configured column by each definition value" do
        expect(scope_queries).to all(satisfy { |sql, value| sql.include?("\"status\" = '#{value}'") })
      end
    end
  end

  describe "Handling an Array definition" do
    let(:definition) { %w[user admin] }
    let(:array_definition_arguments) do
      {
        model_class: TestModel,
        accessor: :role,
        definition: definition,
        options: {},
      }
    end

    before do
      described_class.define(**array_definition_arguments)
    end

    describe "Model.<accessor>_values" do
      let(:output) { TestModel.role_values }

      it "returns values from the definition" do
        expect(output).to match_array(definition)
      end
    end

    describe "Instance.<key>_<accessor>?" do
      let(:record) { TestModel.new(role: definition.last) }
      let(:output) { record.public_send("#{definition.last}_role?") }

      it "returns true for the matching definition" do
        expect(output).to be true
      end
    end
  end
end
