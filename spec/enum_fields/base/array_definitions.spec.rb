# frozen_string_literal: true

RSpec.describe EnumFields::Base, 'Array Definitions' do
  include_context 'with TestModel'

  let(:definitions) { %w[value1 value2] }

  before do
    TestModel.enum_field :sample_column, definitions
  end

  describe 'Model.<accessor>s' do
    it 'defines definitions method on the class' do
      expect(TestModel).to respond_to(:sample_columns)
    end

    it 'returns definitions as a hash with :value & :label properties' do
      expect(TestModel.sample_columns).to match({
        value1: {
          value: 'value1',
          label: 'value1',
        },
        value2: {
          value: 'value2',
          label: 'value2',
        },
      })
    end
  end
end
