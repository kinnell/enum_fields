# frozen_string_literal: true

RSpec.shared_context 'with TestModel' do
  let(:test_model_class) do
    Class.new(MockActiveRecord::Base) do
      include EnumFields

      def self.name
        'TestModel'
      end
    end
  end

  before do
    stub_const('TestModel', test_model_class)
  end

  let(:record) { TestModel.new(sample_column: sample_column_value) }
  let(:sample_column_value) { 'value1' }
end
