# frozen_string_literal: true

RSpec.shared_context "with TestModel" do
  let(:test_model_class) do
    Class.new(MockActiveRecord::Base) do
      include EnumFields

      def self.name
        "TestModel"
      end
    end
  end

  before do
    stub_const("TestModel", test_model_class)
  end

  let(:record) do
    TestModel.new({
      status: status_value,
      category: category_value,
    })
  end

  let(:status_value) { "draft" }
  let(:category_value) { "blog" }
end
