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

  before do
    TestModel.enum_field :status, definitions
    TestModel.enum_field :category, category_definitions
  end

  describe "Model.enum_field_for" do
    context "when the accessor is defined" do
      let(:accessor) { :status }

      it "returns the definition" do
        expect(TestModel.enum_field_for(accessor)).to match(definitions)
      end
    end

    context "when the accessor is not defined" do
      let(:accessor) { :priority }

      it "returns nil" do
        expect(TestModel.enum_field_for(accessor)).to be_nil
      end
    end
  end

  describe "Model.enum_field?" do
    context "when the accessor is defined" do
      let(:accessor) { :status }

      it "returns true" do
        expect(TestModel.enum_field?(accessor)).to be_truthy
      end
    end

    context "when the accessor is not defined" do
      let(:accessor) { :priority }

      it "returns false" do
        expect(TestModel.enum_field?(accessor)).to be_falsey
      end
    end
  end

  describe "Model.<accessor>s" do
    it "defines definitions method on the class" do
      expect(TestModel).to respond_to(:statuses)
    end

    it "returns definitions as a hash" do
      expect(TestModel.statuses).to match(definitions)
    end
  end

  describe "Model.<accessor>s_count" do
    it "defines definitions count method on the class" do
      expect(TestModel).to respond_to(:statuses_count)
    end

    it "returns the number of definitions" do
      expect(TestModel.statuses_count).to eq(definitions.size)
    end
  end

  describe "Model.<accessor>_values" do
    it "defines definitions values method on the class" do
      expect(TestModel).to respond_to(:status_values)
    end

    it "returns the values of the definitions" do
      expect(TestModel.status_values).to eq(%w[draft published])
    end
  end

  describe "Model.<accessor>_options" do
    it "defines definitions options method on the class" do
      expect(TestModel).to respond_to(:status_options)
    end

    it "returns the options of the definitions" do
      expect(TestModel.status_options).to match(definitions.map { |key, definition|
        [definition[:label], key.to_s]
      })
    end
  end

  describe "Model.<key>_<accessor>_value" do
    it "defines value accessor methods for each key on the class" do
      expect(TestModel).to respond_to(:draft_status_value)
      expect(TestModel).to respond_to(:published_status_value)
    end

    it "returns the value for each key" do
      expect(TestModel.draft_status_value).to eq("draft")
      expect(TestModel.published_status_value).to eq("published")
    end
  end

  describe "Instance.enum_fields_metadata" do
    it "defines enum_fields_metadata method on the instance" do
      expect(record).to respond_to(:enum_fields_metadata)
    end

    it "returns a HashWithIndifferentAccess" do
      expect(record.enum_fields_metadata).to be_a(HashWithIndifferentAccess)
    end

    it "returns the metadata of the accessor" do
      expect(record.enum_fields_metadata).to match({
        status: definitions[record.status.to_sym],
        category: category_definitions[record.category.to_sym],
      })
    end
  end

  describe "Instance.<accessor>" do
    it "defines getter method on the instance" do
      expect(record).to respond_to(:status)
    end

    it "returns the value of the accessor" do
      expect(record.status).to eq(status_value)
    end
  end

  describe "Instance.<accessor>=" do
    it "defines setter method on the instance" do
      expect(record).to respond_to(:status=)
    end

    it "sets the value of the accessor" do
      expect(record.status).to eq(status_value)
    end
  end

  describe "Instance.<accessor>_metadata" do
    it "defines metadata method on the instance" do
      expect(record).to respond_to(:status_metadata)
    end

    it "returns the metadata of the accessor" do
      expect(record.status_metadata).to match(definitions[:draft])
    end
  end

  describe "Instance.<accessor>_value" do
    it "defines value method on the instance" do
      expect(record).to respond_to(:status_value)
    end

    it "returns the value of the accessor" do
      expect(record.status_value).to eq(definitions.dig(:draft, :value))
    end
  end

  describe "Instance.<accessor>_label" do
    it "defines label method on the instance" do
      expect(record).to respond_to(:status_label)
    end

    it "returns the label of the accessor" do
      expect(record.status_label).to eq(definitions.dig(:draft, :label))
    end
  end

  describe "Instance.<accessor>_icon" do
    it "defines icon method on the instance" do
      expect(record).to respond_to(:status_icon)
    end

    it "returns the icon of the accessor" do
      expect(record.status_icon).to eq(definitions.dig(:draft, :icon))
    end
  end

  describe "Instance.<accessor>_color" do
    it "defines color method on the instance" do
      expect(record).to respond_to(:status_color)
    end

    it "returns the color of the accessor" do
      expect(record.status_color).to eq(definitions.dig(:draft, :color))
    end
  end

  describe "Instance.<accessor>_tooltip" do
    it "defines tooltip method on the instance" do
      expect(record).to respond_to(:status_tooltip)
    end

    it "returns the tooltip of the accessor" do
      expect(record.status_tooltip).to eq(definitions.dig(:draft, :tooltip))
    end
  end

  describe "Instance.<accessor>?" do
    it "defines inquiry methods on the instance" do
      expect(record).to respond_to(:draft_status?)
      expect(record).to respond_to(:published_status?)
    end

    it "returns true if the accessor is draft" do
      expect(record.draft_status?).to be_truthy
      expect(record.published_status?).to be_falsey
    end
  end

  describe "Model.<key>_<accessor>" do
    it "defines scope methods on the class" do
      expect(TestModel).to respond_to(:draft_status)
      expect(TestModel).to respond_to(:published_status)
    end

    it "returns the records with the draft scope" do
      expect(TestModel.draft_status.to_sql).to match(%r{
        \ASELECT\s+"with_model_test_models_\d+_\d+"\.\*
        \s+FROM\s+"with_model_test_models_\d+_\d+"
        \s+WHERE\s+"with_model_test_models_\d+_\d+"\."status"\s+=\s+'draft
      }x)
    end

    it "returns the records with the published scope" do
      expect(TestModel.published_status.to_sql).to match(%r{
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
