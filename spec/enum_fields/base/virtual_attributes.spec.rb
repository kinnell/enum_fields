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
    defs = definitions

    Class.new(MockActiveRecord::Base) do
      include EnumFields

      def self.name
        "TestModel"
      end

      enum_field :speed, defs, scope: false, validate: false

      define_method(:speed) do
        "fast"
      end
    end
  end

  before do
    stub_const("TestModel", test_model_class)
  end

  let(:record) { TestModel.new }

  describe "class methods" do
    it "defines the collection method" do
      expect(TestModel.speeds).to match(definitions)
    end

    it "defines the count method" do
      expect(TestModel.speeds_count).to eq(3)
    end

    it "defines the values method" do
      expect(TestModel.speed_values).to eq(%w[fast normal slow])
    end

    it "defines the options method" do
      expect(TestModel.speed_options).to eq([
        ["Fast (< 1m)", "fast"],
        ["Normal (< 1hr)", "normal"],
        ["Slow (> 1hr)", "slow"],
      ])
    end

    it "defines value accessor methods for each key" do
      expect(TestModel.fast_speed_value).to eq("fast")
      expect(TestModel.normal_speed_value).to eq("normal")
      expect(TestModel.slow_speed_value).to eq("slow")
    end
  end

  describe "Instance.<accessor>_metadata" do
    it "returns the metadata matching the method's return value" do
      expect(record.speed_metadata).to match(definitions[:fast])
    end

    context "when the method returns nil" do
      before do
        test_model_class.define_method(:speed) { nil }
      end

      it "returns nil" do
        expect(record.speed_metadata).to be_nil
      end
    end
  end

  describe "Instance.<accessor>_<property>" do
    it "returns the label for the current value" do
      expect(record.speed_label).to eq("Fast (< 1m)")
    end

    it "returns the value for the current value" do
      expect(record.speed_value).to eq("fast")
    end

    context "when the method returns nil" do
      before do
        test_model_class.define_method(:speed) { nil }
      end

      it "returns nil for label" do
        expect(record.speed_label).to be_nil
      end

      it "returns nil for value" do
        expect(record.speed_value).to be_nil
      end
    end
  end

  describe "Instance.<key>_<accessor>?" do
    it "returns true when the method returns the matching value" do
      expect(record.fast_speed?).to be true
    end

    it "returns false for non-matching values" do
      expect(record.normal_speed?).to be false
      expect(record.slow_speed?).to be false
    end

    context "when the method returns a different value" do
      before do
        test_model_class.define_method(:speed) { "slow" }
      end

      it "matches the new return value" do
        expect(record.slow_speed?).to be true
        expect(record.fast_speed?).to be false
      end
    end
  end

end
