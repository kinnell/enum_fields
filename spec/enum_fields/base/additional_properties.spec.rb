# frozen_string_literal: true

RSpec.describe EnumFields::Base, 'Additional Properties' do
  include_context 'with TestModel'

  let(:definitions) do
    {
      value1: {
        value: 'value1',
        label: 'Value 1',
        additional_property: 'additional_value1',
      },
      value2: {
        value: 'value2',
        label: 'Value 2',
        additional_property: 'additional_value2',
      },
    }
  end

  before do
    TestModel.enum_field :sample_column, definitions
  end

  describe 'Model.<accessor>s' do
    it 'returns definitions as a hash with the additional properties' do
      expect(TestModel.sample_columns).to match(definitions)
    end
  end

  describe 'Instance.<accessor>_metadata' do
    it 'returns the metadata of the accessor with the additional properties' do
      expect(record.sample_column_metadata).to match(definitions[:value1])
    end
  end

  describe 'Instance.<accessor>_<property>' do
    it 'returns the value of the additional property' do
      expect(record.sample_column_additional_property).to eq(definitions[:value1][:additional_property])
    end
  end
end
