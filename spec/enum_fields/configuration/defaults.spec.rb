# frozen_string_literal: true

RSpec.describe EnumFields::Configuration do
  subject(:configuration) { described_class.new }

  describe "defaults" do
    it "sets :scopeable to true" do
      expect(configuration.scopeable).to be true
    end

    it "sets :validatable to true" do
      expect(configuration.validatable).to be true
    end

    it "sets :nullable to true" do
      expect(configuration.nullable).to be true
    end

    it "sets :inquirable to true" do
      expect(configuration.inquirable).to be true
    end
  end

  describe "#reset!" do
    before do
      configuration.scopeable = false
      configuration.validatable = false
      configuration.nullable = false
      configuration.inquirable = false
      configuration.reset!
    end

    it "restores :scopeable to default" do
      expect(configuration.scopeable).to be true
    end

    it "restores :validatable to default" do
      expect(configuration.validatable).to be true
    end

    it "restores :nullable to default" do
      expect(configuration.nullable).to be true
    end

    it "restores :inquirable to default" do
      expect(configuration.inquirable).to be true
    end
  end
end
