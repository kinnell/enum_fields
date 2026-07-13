# frozen_string_literal: true

RSpec.describe EnumFields::Base, "Virtual Attributes" do
  let(:definitions) do
    {
      fast: {
        value: "fast",
        label: "Fast (< 1m)",
      },
      normal: {
        value: "normal",
        label: "Normal (< 1hr)",
      },
      slow: {
        value: "slow",
        label: "Slow (> 1hr)",
      },
    }
  end

  let(:test_model_class) do
    Class.new(MockActiveRecord::Base) do
      include EnumFields

      def self.name
        "TestModel"
      end

      define_method(:speed) do
        "fast"
      end
    end
  end

  before do
    stub_const("TestModel", test_model_class)
    TestModel.enum_field :speed, definitions, scopeable: false, validatable: false
  end

  let(:record) { TestModel.new }

  describe "Model.<accessor>s" do
    let(:output) { TestModel.speeds }

    it "returns the definitions" do
      expect(output).to match(definitions)
    end
  end

  describe "Model.<accessor>s_count" do
    let(:output) { TestModel.speeds_count }

    it "returns the definition count" do
      expect(output).to eq(3)
    end
  end

  describe "Model.<accessor>_values" do
    let(:output) { TestModel.speed_values }

    it "returns the definition values" do
      expect(output).to eq(%w[fast normal slow])
    end
  end

  describe "Model.<accessor>_options" do
    let(:output) { TestModel.speed_options }

    it "returns the definition options" do
      expect(output).to eq([
        ["Fast (< 1m)", "fast"],
        ["Normal (< 1hr)", "normal"],
        ["Slow (> 1hr)", "slow"],
      ])
    end
  end

  describe "Model.<key>_<accessor>_value" do
    let(:output) do
      definitions.keys.to_h { |key| [key, TestModel.public_send("#{key}_speed_value")] }
    end
    let(:expected_output) { definitions.transform_values { |metadata| metadata[:value] } }

    it "returns the value for each definition" do
      expect(output).to eq(expected_output)
    end
  end

  describe "Instance.<accessor>_metadata" do
    let(:output) { record.speed_metadata }

    it "returns the metadata matching the method's return value" do
      expect(output).to match(definitions[:fast])
    end

    context "when the method returns nil" do
      before do
        test_model_class.define_method(:speed) { nil }
      end

      it "returns nil" do
        expect(output).to be_nil
      end
    end
  end

  describe "Instance.<accessor>_<property>" do
    let(:label) { record.speed_label }
    let(:value) { record.speed_value }

    it "returns the label for the current value" do
      expect(label).to eq("Fast (< 1m)")
    end

    it "returns the value for the current value" do
      expect(value).to eq("fast")
    end

    context "when the method returns nil" do
      before do
        test_model_class.define_method(:speed) { nil }
      end

      it "returns nil for label" do
        expect(label).to be_nil
      end

      it "returns nil for value" do
        expect(value).to be_nil
      end
    end
  end

  describe "Instance.<key>_<accessor>?" do
    let(:output) do
      definitions.keys.to_h { |key| [key, record.public_send("#{key}_speed?")] }
    end
    let(:expected_output) do
      definitions.transform_values { |metadata| record.speed == metadata[:value] }
    end

    it "returns whether the accessor matches each definition" do
      expect(output).to eq(expected_output)
    end

    context "when the method returns a different value" do
      before do
        test_model_class.define_method(:speed) { "slow" }
      end

      it "returns whether the accessor matches each definition" do
        expect(output).to eq(expected_output)
      end
    end
  end
end
