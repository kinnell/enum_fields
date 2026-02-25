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

  before do
    TestModel.enum_field :state, definitions, column: :status
  end

  describe "Model.<accessor>s" do
    it "defines definitions method on the class for the accessor" do
      expect(TestModel).to respond_to(:states)
    end

    it "does not define definitions method on the class for the column" do
      expect(TestModel).not_to respond_to(:statuses)
    end

    it "returns definitions as a hash for the accessor" do
      expect(TestModel.states).to match(definitions)
    end
  end

  describe "Model.<accessor>s_count" do
    it "defines definitions count method on the class for the accessor" do
      expect(TestModel).to respond_to(:states_count)
    end

    it "does not define definitions count method on the class for the column" do
      expect(TestModel).not_to respond_to(:statuses_count)
    end

    it "returns the number of definitions for the accessor" do
      expect(TestModel.states_count).to eq(definitions.size)
    end
  end

  describe "Model.<accessor>_values" do
    it "defines definitions values method on the class for the accessor" do
      expect(TestModel).to respond_to(:state_values)
    end

    it "does not define definitions values method on the class for the column" do
      expect(TestModel).not_to respond_to(:status_values)
    end

    it "returns the values of the definitions for the accessor" do
      expect(TestModel.state_values).to eq(%w[draft published])
    end
  end

  describe "Model.<accessor>_options" do
    it "defines definitions options method on the class for the accessor" do
      expect(TestModel).to respond_to(:state_options)
    end

    it "does not define definitions options method on the class for the column" do
      expect(TestModel).not_to respond_to(:status_options)
    end

    it "returns the options of the definitions for the accessor" do
      expect(TestModel.state_options).to match(definitions.map { |key, definition|
        [definition[:label], key.to_s]
      })
    end
  end

  describe "Instance.<accessor>" do
    it "defines getter method on the instance for the accessor" do
      expect(record).to respond_to(:state)
    end

    it "retains the original getter method on the instance for the column" do
      expect(record).to respond_to(:status)
    end

    it "returns the value of the accessor" do
      expect(record.state).to eq(status_value)
    end
  end

  describe "Instance.<accessor>=" do
    it "defines setter method on the instance for the accessor" do
      expect(record).to respond_to(:state=)
    end

    it "retains the original setter method on the instance for the column" do
      expect(record).to respond_to(:status=)
    end

    it "sets the value of the accessor" do
      expect(record.state).to eq(status_value)
    end
  end

  describe "Instance.<accessor>_metadata" do
    it "defines metadata method on the instance for the accessor" do
      expect(record).to respond_to(:state_metadata)
    end

    it "does not define metadata method on the instance for the column" do
      expect(record).not_to respond_to(:status_metadata)
    end

    it "returns the metadata of the accessor" do
      expect(record.state_metadata).to match(definitions[:draft])
    end
  end

  describe "Instance.<accessor>_value" do
    it "defines value method on the instance for the accessor" do
      expect(record).to respond_to(:state_value)
    end

    it "does not define value method on the instance for the column" do
      expect(record).not_to respond_to(:status_value)
    end

    it "returns the value of the accessor" do
      expect(record.state_value).to eq(definitions.dig(:draft, :value))
    end
  end

  describe "Instance.<accessor>_label" do
    it "defines label method on the instance for the accessor" do
      expect(record).to respond_to(:state_label)
    end

    it "does not define label method on the instance for the column" do
      expect(record).not_to respond_to(:status_label)
    end

    it "returns the label of the accessor" do
      expect(record.state_label).to eq(definitions.dig(:draft, :label))
    end
  end

  describe "Instance.<accessor>?" do
    it "defines inquiry methods on the instance for the accessor" do
      expect(record).to respond_to(:draft_state?)
      expect(record).to respond_to(:published_state?)
    end

    it "does not define inquiry methods on the instance for the column" do
      expect(record).not_to respond_to(:draft_status?)
      expect(record).not_to respond_to(:published_status?)
    end

    it "returns true if the accessor is draft" do
      expect(record.draft_state?).to be_truthy
      expect(record.published_state?).to be_falsey
    end
  end

  describe "Model.<key>_<accessor>" do
    it "defines scope methods on the class for the accessor" do
      expect(TestModel).to respond_to(:draft_state)
      expect(TestModel).to respond_to(:published_state)
    end

    it "does not define scope methods on the class for the column" do
      expect(TestModel).not_to respond_to(:draft_status)
      expect(TestModel).not_to respond_to(:published_status)
    end

    it "returns the records with the draft scope" do
      expect(TestModel.draft_state.to_sql).to match(%r{
        \ASELECT\s+"with_model_test_models_\d+_\d+"\.\*
        \s+FROM\s+"with_model_test_models_\d+_\d+"
        \s+WHERE\s+"with_model_test_models_\d+_\d+"\."status"\s+=\s+'draft
      }x)
    end

    it "returns the records with the published scope" do
      expect(TestModel.published_state.to_sql).to match(%r{
        \ASELECT\s+"with_model_test_models_\d+_\d+"\.\*
        \s+FROM\s+"with_model_test_models_\d+_\d+"
        \s+WHERE\s+"with_model_test_models_\d+_\d+"\."status"\s+=\s+'published
      }x)
    end
  end

  describe "Instance validation" do
    context "when the accessor value is in the list of definitions" do
      let(:status_value) { "draft" }

      before do
        record.update(status: status_value)
      end

      it "is valid" do
        expect(record).to be_valid
      end
    end

    context "when the accessor value is not in the list of definitions" do
      let(:status_value) { "archived" }

      before do
        record.update(status: status_value)
      end

      it "is not valid" do
        expect(record).to be_invalid
      end
    end
  end
end
