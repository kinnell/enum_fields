# frozen_string_literal: true

RSpec.describe EnumFields, "Global Configuration" do
  after { EnumFields.reset_configuration! }

  describe ".configure" do
    before do
      EnumFields.configure do |config|
        config.validatable = false
        config.scopeable = false
        config.inquirable = false
      end
    end

    it "sets :validatable on the configuration" do
      expect(EnumFields.configuration.validatable).to be false
    end

    it "sets :scopeable on the configuration" do
      expect(EnumFields.configuration.scopeable).to be false
    end

    it "sets :inquirable on the configuration" do
      expect(EnumFields.configuration.inquirable).to be false
    end
  end

  describe ".configuration" do
    it "returns a Configuration instance" do
      expect(EnumFields.configuration).to be_a(EnumFields::Configuration)
    end

    it "returns the same instance on repeated calls" do
      expect(EnumFields.configuration).to equal(EnumFields.configuration)
    end
  end

  describe ".reset_configuration!" do
    before do
      EnumFields.configure do |config|
        config.validatable = false
      end
      EnumFields.reset_configuration!
    end

    it "restores defaults" do
      expect(EnumFields.configuration.validatable).to be true
    end
  end
end
