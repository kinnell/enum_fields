# frozen_string_literal: true

RSpec.describe EnumFields do
  after { described_class.reset_configuration! }

  describe ".configure" do
    context "when configuring :validatable" do
      let(:output) { described_class.configuration.validatable }

      before do
        described_class.configure do |configuration|
          configuration.validatable = false
        end
      end

      it "applies the setting" do
        expect(output).to be(false)
      end
    end

    context "when configuring :scopeable" do
      let(:output) { described_class.configuration.scopeable }

      before do
        described_class.configure do |configuration|
          configuration.scopeable = false
        end
      end

      it "applies the setting" do
        expect(output).to be(false)
      end
    end

    context "when configuring :inquirable" do
      let(:output) { described_class.configuration.inquirable }

      before do
        described_class.configure do |configuration|
          configuration.inquirable = false
        end
      end

      it "applies the setting" do
        expect(output).to be(false)
      end
    end

    context "when configuring :nullable" do
      let(:output) { described_class.configuration.nullable }

      before do
        described_class.configure do |configuration|
          configuration.nullable = false
        end
      end

      it "applies the setting" do
        expect(output).to be(false)
      end
    end
  end

  describe ".configuration" do
    let(:configuration1) { described_class.configuration }
    let(:configuration2) { described_class.configuration }

    it "returns a Configuration instance" do
      expect(configuration1).to be_a(EnumFields::Configuration)
    end

    it "returns the same instance across calls" do
      expect(configuration1).to equal(configuration2)
    end

    context "when a setting is changed" do
      before { configuration1.validatable = false }

      it "retains the change across accesses" do
        expect(configuration2.validatable).to be(false)
      end
    end
  end

  describe ".reset_configuration!" do
    let(:output) { described_class.configuration.validatable }

    before do
      described_class.configure do |configuration|
        configuration.validatable = false
      end
      described_class.reset_configuration!
    end

    it "restores default settings" do
      expect(output).to be(true)
    end
  end
end
