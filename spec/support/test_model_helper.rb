# frozen_string_literal: true

module TestModelHelper
  def create_test_model(&block)
    model_class = Class.new(MockActiveRecord::Base) do
      include EnumFields

      def self.name
        "TestModel"
      end

      class_eval(&block) if block
    end

    stub_const("TestModel", model_class)
    model_class
  end
end

RSpec.configure do |config|
  config.include TestModelHelper
end
