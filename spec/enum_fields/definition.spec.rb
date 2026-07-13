# frozen_string_literal: true

require "spec_helper"

RSpec.describe EnumFields::Definition do
  subject(:definition) { described_class.new(data) }

  let(:data) do
    {
      pending: {
        value: "pending",
        label: "Pending",
      },
      active: {
        value: "active",
        label: "Active",
      },
    }
  end

  describe "#initialize" do
    context "when :data is a Hash" do
      let(:output) { definition.data }

      it "preserves the definitions" do
        expect(output).to match(data)
      end

      it "returns a HashWithIndifferentAccess" do
        expect(output).to be_a(HashWithIndifferentAccess)
      end
    end

    context "when :data is a HashWithIndifferentAccess" do
      let(:data) do
        {
          pending: {
            value: "pending",
            label: "Pending",
          },
        }.with_indifferent_access
      end
      let(:output) { definition.data }

      it "preserves the definitions" do
        expect(output).to eq(data)
      end
    end

    context "when :data is an Array of values" do
      let(:data) do
        %w[
          pending
          active
          archived
        ]
      end
      let(:output) { definition.data }

      it "builds definitions with labels" do
        expect(output).to match({
          pending: {
            value: "pending",
            label: "pending",
          },
          active: {
            value: "active",
            label: "active",
          },
          archived: {
            value: "archived",
            label: "archived",
          },
        })
      end
    end

    context "when :data is an Array of Hashes with string values" do
      let(:data) do
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
      let(:output) { definition.data }

      it "keys definitions by value" do
        expect(output).to match({
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

      context "when an entry has additional properties" do
        let(:data) do
          [
            {
              value: "small",
              label: "Small",
              icon: "arrow_down",
            },
          ]
        end
        let(:output) { definition.data[:small] }

        it "preserves the additional properties" do
          expect(output).to match({
            value: "small",
            label: "Small",
            icon: "arrow_down",
          })
        end
      end

      context "when an entry omits :label" do
        let(:data) do
          [
            {
              value: "small",
            },
          ]
        end
        let(:output) { definition.data[:small] }

        it "uses the value as the label" do
          expect(output).to match({
            value: "small",
            label: "small",
          })
        end
      end
    end

    context "when :data is an Array of Hashes with integer values" do
      let(:data) do
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
      let(:output) { definition.data }

      it "keys definitions by value" do
        expect(output).to match({
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

    context "when :data is a String" do
      let(:data) { "invalid" }
      let(:output) { described_class.new(data) }

      it "rejects the definitions" do
        expect { output }.to raise_error(EnumFields::InvalidDefinitionsError)
      end
    end

    context "when :data is an Integer" do
      let(:data) { 123 }
      let(:output) { described_class.new(data) }

      it "rejects the definitions" do
        expect { output }.to raise_error(EnumFields::InvalidDefinitionsError)
      end
    end

    context "when :data is nil" do
      let(:data) { nil }
      let(:output) { described_class.new(data) }

      it "rejects the definitions" do
        expect { output }.to raise_error(EnumFields::InvalidDefinitionsError)
      end
    end

    context "when :data omits :value" do
      let(:data) do
        {
          pending: {
            label: "Pending",
          },
        }
      end
      let(:output) { described_class.new(data) }

      it "rejects the definitions" do
        expect { output }.to raise_error(EnumFields::InvalidDefinitionsError)
      end
    end
  end

  describe "#valid?" do
    let(:output) { definition.valid? }

    it "recognizes valid definitions" do
      expect(output).to be(true)
    end
  end

  describe "#each" do
    let(:output) { definition.each.map(&:first) }

    it "iterates over every definition" do
      expect(output).to contain_exactly("pending", "active")
    end
  end

  describe "#[]" do
    let(:output) { definition[key] }

    context "with a symbol key" do
      let(:key) { :pending }

      it "retrieves the metadata" do
        expect(output).to match({
          value: "pending",
          label: "Pending",
        })
      end
    end

    context "with a string key" do
      let(:key) { "pending" }

      it "retrieves the metadata" do
        expect(output).to match({
          value: "pending",
          label: "Pending",
        })
      end
    end
  end

  describe "#keys" do
    let(:output) { definition.keys }

    it "returns every definition key" do
      expect(output).to contain_exactly("pending", "active")
    end
  end

  describe "#values" do
    let(:output) { definition.values }

    it "returns every definition" do
      expect(output).to match([
        {
          value: "pending",
          label: "Pending",
        },
        {
          value: "active",
          label: "Active",
        },
      ])
    end
  end

  describe "#dig" do
    let(:output) { definition.dig(:pending, :label) }

    it "retrieves nested metadata" do
      expect(output).to eq("Pending")
    end
  end

  describe "#size" do
    let(:output) { definition.size }

    it "reports the definition count" do
      expect(output).to eq(2)
    end
  end

  describe "#map" do
    let(:output) { definition.map { |key, _metadata| key } }

    it "transforms every definition" do
      expect(output).to contain_exactly("pending", "active")
    end
  end

  describe "#blank?" do
    let(:output) { definition.blank? }

    context "when definitions are empty" do
      let(:data) { {} }

      it "recognizes empty definitions" do
        expect(output).to be(true)
      end
    end

    context "when definitions are present" do
      it "recognizes populated definitions" do
        expect(output).to be(false)
      end
    end
  end
end
