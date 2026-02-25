# frozen_string_literal: true

require "spec_helper"

RSpec.describe EnumFields::Definition do
  subject { described_class.new(data) }

  describe "#initialize" do
    context "when data is a Hash" do
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

      it "converts to HashWithIndifferentAccess" do
        expect(subject.data).to be_a(HashWithIndifferentAccess)
      end

      it "preserves the hash data" do
        expect(subject.data).to match(data)
      end
    end

    context "when data is a HashWithIndifferentAccess" do
      let(:data) do
        {
          pending: {
            value: "pending",
            label: "Pending",
          },
        }.with_indifferent_access
      end

      it "uses the hash directly" do
        expect(subject.data).to eq(data)
      end
    end

    context "when data is an Array" do
      let(:data) do
        %w[
          pending
          active
          archived
        ]
      end

      it "converts to hash with value and label" do
        expect(subject.data).to match({
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

      it "creates entries for all array elements" do
        expect(subject.data.keys).to match(data)
      end
    end

    context "when data is an Array of Hashes with string values" do
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

      it "converts to hash keyed by symbolized value" do
        expect(subject.data).to match({
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

      it "creates entries for all array elements" do
        expect(subject.data.keys).to match_array(%w[small medium large])
      end

      it "preserves additional properties" do
        definition = described_class.new([
          {
            value: "small",
            label: "Small",
            icon: "arrow_down",
          },
        ])
        expect(definition.data[:small][:icon]).to eq("arrow_down")
      end

      it "defaults label to value when label is missing" do
        definition = described_class.new([
          {
            value: "small",
          },
        ])
        expect(definition.data[:small][:label]).to eq("small")
      end
    end

    context "when data is an Array of Hashes with integer values" do
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

      it "converts to hash keyed by symbolized value" do
        expect(subject.data).to match({
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

      it "creates entries for all array elements" do
        expect(subject.data.keys).to match_array(%w[1 2 3])
      end
    end

    context "when data is a String" do
      let(:data) { "invalid" }

      it "raises InvalidDefinitionsError" do
        expect { subject }.to raise_error(EnumFields::InvalidDefinitionsError)
      end
    end

    context "when data is an Integer" do
      let(:data) { 123 }

      it "raises InvalidDefinitionsError" do
        expect { subject }.to raise_error(EnumFields::InvalidDefinitionsError)
      end
    end

    context "when data is a nil" do
      let(:data) { nil }

      it "raises InvalidDefinitionsError" do
        expect { subject }.to raise_error(EnumFields::InvalidDefinitionsError)
      end
    end

    context "when data is missing :value property" do
      let(:data) do
        {
          pending: {
            label: "Pending",
          },
        }
      end

      it "raises InvalidDefinitionsError" do
        expect { subject }.to raise_error(EnumFields::InvalidDefinitionsError)
      end
    end
  end

  describe "#valid?" do
    context "when data is valid" do
      let(:data) do
        {
          pending: {
            value: "pending",
            label: "Pending",
          },
        }
      end

      it "returns true" do
        expect(subject.valid?).to be(true)
      end
    end
  end

  describe "#each" do
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

    it "iterates over the data" do
      expect(subject.each.map(&:first)).to contain_exactly("pending", "active")
    end
  end

  describe "#[]" do
    let(:data) do
      {
        pending: {
          value: "pending",
          label: "Pending",
        },
      }
    end

    it "returns the value for the key" do
      expect(subject[:pending][:value]).to eq("pending")
      expect(subject[:pending][:label]).to eq("Pending")
    end
  end

  describe "#keys" do
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

    it "returns all keys" do
      expect(subject.keys).to contain_exactly("pending", "active")
    end
  end

  describe "#values" do
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

    it "returns all values" do
      expect(subject.values).to match([
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
    let(:data) do
      {
        pending: {
          value: "pending",
          label: "Pending",
        },
      }
    end

    it "digs into nested hash" do
      expect(subject.dig(:pending, :label)).to eq("Pending")
    end
  end

  describe "#size" do
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

    it "returns the number of definitions" do
      expect(subject.size).to eq(2)
    end
  end

  describe "#map" do
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

    it "maps over the data" do
      expect(subject.map { |key, _| key }).to contain_exactly("pending", "active")
    end
  end

  describe "#blank?" do
    context "when data is empty" do
      let(:data) { {} }

      it "returns true" do
        expect(subject.blank?).to be(true)
      end
    end

    context "when data is present" do
      let(:data) do
        {
          pending: {
            value: "pending",
          },
        }
      end

      it "returns false" do
        expect(subject.blank?).to be(false)
      end
    end
  end
end
