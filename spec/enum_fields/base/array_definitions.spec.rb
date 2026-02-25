# frozen_string_literal: true

RSpec.describe EnumFields::Base, "Array Definitions" do
  include_context "with TestModel"

  context "with simple array of string values" do
    let(:definitions) { %w[red green blue] }

    before do
      TestModel.enum_field :color, definitions
    end

    describe "Model.<accessor>s" do
      it "defines definitions method on the class" do
        expect(TestModel).to respond_to(:colors)
      end

      it "returns definitions as a hash with :value & :label properties" do
        expect(TestModel.colors).to match({
          red: {
            value: "red",
            label: "red",
          },
          green: {
            value: "green",
            label: "green",
          },
          blue: {
            value: "blue",
            label: "blue",
          },
        })
      end
    end
  end

  context "with simple array of integer values" do
    let(:definitions) { [1, 2, 3] }

    before do
      TestModel.enum_field :quantity, definitions
    end

    describe "Model.<accessor>s" do
      it "defines definitions method on the class" do
        expect(TestModel).to respond_to(:quantities)
      end

      it "returns definitions as a hash with :value & :label properties" do
        expect(TestModel.quantities).to match({
          "1": {
            value: 1,
            label: "1",
          },
          "2": {
            value: 2,
            label: "2",
          },
          "3": {
            value: 3,
            label: "3",
          },
        })
      end
    end
  end

  context "with array of hashes with string values" do
    let(:definitions) do
      [
        {
          value: "small",
          label: "Small",
        },
        {
          value: "medium",
          label: "Medium",
        },
        {
          value: "large",
          label: "Large",
        },
      ]
    end

    before do
      TestModel.enum_field :size, definitions
    end

    describe "Model.<accessor>s" do
      it "defines definitions method on the class" do
        expect(TestModel).to respond_to(:sizes)
      end

      it "returns definitions keyed by symbolized value" do
        expect(TestModel.sizes).to match({
          small: {
            value: "small",
            label: "Small",
          },
          medium: {
            value: "medium",
            label: "Medium",
          },
          large: {
            value: "large",
            label: "Large",
          },
        })
      end
    end

    describe "Model.<accessor>_values" do
      it "returns the values" do
        expect(TestModel.size_values).to match_array(%w[small medium large])
      end
    end
  end

  context "with array of hashes with integer values" do
    let(:definitions) do
      [
        {
          value: 1,
          label: "Low",
        },
        {
          value: 2,
          label: "Medium",
        },
        {
          value: 3,
          label: "High",
        },
      ]
    end

    before do
      TestModel.enum_field :difficulty, definitions
    end

    describe "Model.<accessor>s" do
      it "defines definitions method on the class" do
        expect(TestModel).to respond_to(:difficulties)
      end

      it "returns definitions keyed by symbolized value" do
        expect(TestModel.difficulties).to match({
          "1": {
            value: 1,
            label: "Low",
          },
          "2": {
            value: 2,
            label: "Medium",
          },
          "3": {
            value: 3,
            label: "High",
          },
        })
      end
    end

    describe "Model.<accessor>_values" do
      it "returns the values" do
        expect(TestModel.difficulty_values).to match_array([1, 2, 3])
      end
    end
  end
end
