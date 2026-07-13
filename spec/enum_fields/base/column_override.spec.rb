# frozen_string_literal: true

RSpec.describe EnumFields::Base, "Column Override" do
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
  let(:current_metadata) { definitions.values.find { |metadata| metadata[:value] == record.status } }

  before do
    TestModel.enum_field :state, definitions, column: :status
  end

  describe "Model.<accessor>s" do
    let(:output) { TestModel.states }

    it "returns definitions as a hash for the accessor" do
      expect(output).to match(definitions)
    end
  end

  describe "Model.<accessor>s_count" do
    let(:output) { TestModel.states_count }

    it "returns the number of definitions for the accessor" do
      expect(output).to eq(definitions.size)
    end
  end

  describe "Model.<accessor>_values" do
    let(:output) { TestModel.state_values }

    it "returns the values of the definitions for the accessor" do
      expect(output).to match_array(definitions.values.pluck(:value))
    end
  end

  describe "Model.<accessor>_options" do
    let(:output) { TestModel.state_options }

    it "returns the options of the definitions for the accessor" do
      expect(output).to match(definitions.map { |_key, definition|
        [definition[:label], definition[:value]]
      })
    end
  end

  describe "Instance.<accessor>" do
    let(:output) { record.state }

    it "returns the value of the accessor" do
      expect(output).to eq(status_value)
    end
  end

  describe "Instance.<accessor>=" do
    let(:new_value) { definitions.values.last[:value] }

    before { record.state = new_value }

    it "sets the value of the accessor" do
      expect(record.status).to eq(new_value)
    end
  end

  describe "Instance.<accessor>_metadata" do
    let(:output) { record.state_metadata }

    it "returns the metadata of the accessor" do
      expect(output).to match(current_metadata)
    end
  end

  describe "Instance.<accessor>_value" do
    let(:output) { record.state_value }

    it "returns the value of the accessor" do
      expect(output).to eq(current_metadata[:value])
    end
  end

  describe "Instance.<accessor>_<property>" do
    let(:output) { record.state_label }

    it "returns an additional property of the accessor" do
      expect(output).to eq(current_metadata[:label])
    end
  end

  describe "Instance.<key>_<accessor>?" do
    let(:output) do
      definitions.keys.to_h { |key| [key, record.public_send("#{key}_state?")] }
    end
    let(:expected_output) do
      definitions.transform_values { |metadata| record.status == metadata[:value] }
    end

    it "returns whether the column matches each definition" do
      expect(output).to eq(expected_output)
    end
  end

  describe "Model.<key>_<accessor>" do
    let(:scope_queries) do
      definitions.map do |key, metadata|
        [TestModel.public_send("#{key}_state").to_sql, metadata[:value]]
      end
    end

    it "filters the column by the value for each definition" do
      expect(scope_queries).to all(satisfy { |sql, value| sql.include?("\"status\" = '#{value}'") })
    end
  end

  describe "Model.<column>s" do
    let(:method_call) { -> { TestModel.statuses } }

    it "does not define the collection method on the column" do
      expect(&method_call).to raise_error(NoMethodError)
    end
  end

  describe "Model.<column>s_count" do
    let(:method_call) { -> { TestModel.statuses_count } }

    it "does not define the count method on the column" do
      expect(&method_call).to raise_error(NoMethodError)
    end
  end

  describe "Model.<column>_values" do
    let(:method_call) { -> { TestModel.status_values } }

    it "does not define the values method on the column" do
      expect(&method_call).to raise_error(NoMethodError)
    end
  end

  describe "Model.<column>_options" do
    let(:method_call) { -> { TestModel.status_options } }

    it "does not define the options method on the column" do
      expect(&method_call).to raise_error(NoMethodError)
    end
  end

  describe "Instance.<column>" do
    let(:output) { record.status }

    it "retains the column getter" do
      expect(output).to eq(status_value)
    end
  end

  describe "Instance.<column>=" do
    let(:new_value) { definitions.values.last[:value] }

    before { record.status = new_value }

    it "retains the column setter" do
      expect(record.status).to eq(new_value)
    end
  end

  describe "Instance.<column>_metadata" do
    let(:method_call) { -> { record.status_metadata } }

    it "does not define the metadata method on the column" do
      expect(&method_call).to raise_error(NoMethodError)
    end
  end

  describe "Instance.<column>_value" do
    let(:method_call) { -> { record.status_value } }

    it "does not define the value method on the column" do
      expect(&method_call).to raise_error(NoMethodError)
    end
  end

  describe "Instance.<column>_<property>" do
    let(:method_call) { -> { record.status_label } }

    it "does not define additional property methods on the column" do
      expect(&method_call).to raise_error(NoMethodError)
    end
  end

  describe "Instance.<key>_<column>?" do
    let(:method_calls) do
      definitions.keys.map { |key| -> { record.public_send("#{key}_status?") } }
    end

    it "does not define inquiry methods on the column" do
      expect(method_calls).to all(raise_error(NoMethodError))
    end
  end

  describe "Model.<key>_<column>" do
    let(:method_calls) do
      definitions.keys.map { |key| -> { TestModel.public_send("#{key}_status") } }
    end

    it "does not define scopes on the column" do
      expect(method_calls).to all(raise_error(NoMethodError))
    end
  end

  describe "Validating Instance.<accessor>" do
    context "when the Instance.<accessor> value is in the list of definitions" do
      let(:status_value) { "draft" }

      before { record.valid? }

      it "is valid" do
        expect(record).to be_valid
      end

      it "does not add an error on the column" do
        expect(record.errors[:status]).to be_empty
      end
    end

    context "when the Instance.<accessor> value is not in the list of definitions" do
      let(:status_value) { "archived" }

      before { record.valid? }

      it "is not valid" do
        expect(record).to be_invalid
      end

      it "adds an error on the column" do
        expect(record.errors[:status]).not_to be_empty
      end
    end
  end
end
