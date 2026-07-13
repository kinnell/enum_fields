# frozen_string_literal: true

RSpec.describe EnumFields::Configuration do
  subject(:configuration) { described_class.new }

  describe "#initialize" do
    describe "#scopeable" do
      let(:output) { configuration.scopeable }

      it "is enabled" do
        expect(output).to be(true)
      end
    end

    describe "#validatable" do
      let(:output) { configuration.validatable }

      it "is enabled" do
        expect(output).to be(true)
      end
    end

    describe "#nullable" do
      let(:output) { configuration.nullable }

      it "is enabled" do
        expect(output).to be(true)
      end
    end

    describe "#inquirable" do
      let(:output) { configuration.inquirable }

      it "is enabled" do
        expect(output).to be(true)
      end
    end
  end

  describe "#reset!" do
    context "with :scopeable disabled" do
      let(:output) { configuration.scopeable }

      before do
        configuration.scopeable = false
        configuration.reset!
      end

      it "restores the default" do
        expect(output).to be(true)
      end
    end

    context "with :validatable disabled" do
      let(:output) { configuration.validatable }

      before do
        configuration.validatable = false
        configuration.reset!
      end

      it "restores the default" do
        expect(output).to be(true)
      end
    end

    context "with :nullable disabled" do
      let(:output) { configuration.nullable }

      before do
        configuration.nullable = false
        configuration.reset!
      end

      it "restores the default" do
        expect(output).to be(true)
      end
    end

    context "with :inquirable disabled" do
      let(:output) { configuration.inquirable }

      before do
        configuration.inquirable = false
        configuration.reset!
      end

      it "restores the default" do
        expect(output).to be(true)
      end
    end
  end
end
