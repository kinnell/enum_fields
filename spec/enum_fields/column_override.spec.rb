# frozen_string_literal: true

RSpec.describe EnumFields, 'Column Override' do
  include_context 'with TestModel'

  let(:definitions) do
    {
      value1: {
        value: 'value1',
        label: 'Value 1',
      },
      value2: {
        value: 'value2',
        label: 'Value 2',
      },
    }
  end

  before do
    TestModel.enum_field :sample_field, definitions, column: :sample_column
  end

  describe 'Model.<accessor>s' do
    it 'defines definitions method on the class for the accessor' do
      expect(TestModel).to respond_to(:sample_fields)
    end

    it 'does not define definitions method on the class for the column' do
      expect(TestModel).not_to respond_to(:sample_columns)
    end

    it 'returns definitions as a hash for the accessor' do
      expect(TestModel.sample_fields).to match(definitions)
    end
  end

  describe 'Model.<accessor>s_count' do
    it 'defines definitions count method on the class for the accessor' do
      expect(TestModel).to respond_to(:sample_fields_count)
    end

    it 'does not define definitions count method on the class for the column' do
      expect(TestModel).not_to respond_to(:sample_columns_count)
    end

    it 'returns the number of definitions for the accessor' do
      expect(TestModel.sample_fields_count).to eq(definitions.size)
    end
  end

  describe 'Model.<accessor>_values' do
    it 'defines definitions values method on the class for the accessor' do
      expect(TestModel).to respond_to(:sample_field_values)
    end

    it 'does not define definitions values method on the class for the column' do
      expect(TestModel).not_to respond_to(:sample_column_values)
    end

    it 'returns the values of the definitions for the accessor' do
      expect(TestModel.sample_field_values).to eq(%w[value1 value2])
    end
  end

  describe 'Model.<accessor>_options' do
    it 'defines definitions options method on the class for the accessor' do
      expect(TestModel).to respond_to(:sample_field_options)
    end

    it 'does not define definitions options method on the class for the column' do
      expect(TestModel).not_to respond_to(:sample_column_options)
    end

    it 'returns the options of the definitions for the accessor' do
      expect(TestModel.sample_field_options).to match(definitions.map { |key, definition|
        [definition[:label], key.to_s]
      })
    end
  end

  describe 'Instance.<accessor>' do
    it 'defines getter method on the instance for the accessor' do
      expect(record).to respond_to(:sample_field)
    end

    it 'retains the original getter method on the instance for the column' do
      expect(record).to respond_to(:sample_column)
    end

    it 'returns the value of the accessor' do
      expect(record.sample_field).to eq(sample_column_value)
    end
  end

  describe 'Instance.<accessor>=' do
    it 'defines setter method on the instance for the accessor' do
      expect(record).to respond_to(:sample_field=)
    end

    it 'retains the original setter method on the instance for the column' do
      expect(record).to respond_to(:sample_column=)
    end

    it 'sets the value of the accessor' do
      expect(record.sample_field).to eq(sample_column_value)
    end
  end

  describe 'Instance.<accessor>_metadata' do
    it 'defines metadata method on the instance for the accessor' do
      expect(record).to respond_to(:sample_field_metadata)
    end

    it 'does not define metadata method on the instance for the column' do
      expect(record).not_to respond_to(:sample_column_metadata)
    end

    it 'returns the metadata of the accessor' do
      expect(record.sample_field_metadata).to match(definitions[:value1])
    end
  end

  describe 'Instance.<accessor>_value' do
    it 'defines value method on the instance for the accessor' do
      expect(record).to respond_to(:sample_field_value)
    end

    it 'does not define value method on the instance for the column' do
      expect(record).not_to respond_to(:sample_column_value)
    end

    it 'returns the value of the accessor' do
      expect(record.sample_field_value).to eq(definitions.dig(:value1, :value))
    end
  end

  describe 'Instance.<accessor>_label' do
    it 'defines label method on the instance for the accessor' do
      expect(record).to respond_to(:sample_field_label)
    end

    it 'does not define label method on the instance for the column' do
      expect(record).not_to respond_to(:sample_column_label)
    end

    it 'returns the label of the accessor' do
      expect(record.sample_field_label).to eq(definitions.dig(:value1, :label))
    end
  end

  describe 'Instance.<accessor>?' do
    it 'defines inquiry methods on the instance for the accessor' do
      expect(record).to respond_to(:value1_sample_field?)
      expect(record).to respond_to(:value2_sample_field?)
    end

    it 'does not define inquiry methods on the instance for the column' do
      expect(record).not_to respond_to(:value1_sample_column?)
      expect(record).not_to respond_to(:value2_sample_column?)
    end

    it 'returns true if the accessor is value1' do
      expect(record.value1_sample_field?).to be_truthy
      expect(record.value2_sample_field?).to be_falsey
    end
  end

  describe 'Model.<key>_<accessor>' do
    it 'defines scope methods on the class for the accessor' do
      expect(TestModel).to respond_to(:value1_sample_field)
      expect(TestModel).to respond_to(:value2_sample_field)
    end

    it 'does not define scope methods on the class for the column' do
      expect(TestModel).not_to respond_to(:value1_sample_column)
      expect(TestModel).not_to respond_to(:value2_sample_column)
    end

    it 'returns the records with the value1 accessor' do
      expect(TestModel.value1_sample_field.to_sql).to match(%r{
        \ASELECT\s+"with_model_test_models_\d+_\d+"\.\*
        \s+FROM\s+"with_model_test_models_\d+_\d+"
        \s+WHERE\s+"with_model_test_models_\d+_\d+"\."sample_column"\s+=\s+'value
      }x)
    end

    it 'returns the records with the value2 accessor' do
      expect(TestModel.value2_sample_field.to_sql).to match(%r{
        \ASELECT\s+"with_model_test_models_\d+_\d+"\.\*
        \s+FROM\s+"with_model_test_models_\d+_\d+"
        \s+WHERE\s+"with_model_test_models_\d+_\d+"\."sample_column"\s+=\s+'value
      }x)
    end
  end

  describe 'Instance validation' do
    context 'when the accessor value is in the list of definitions' do
      let(:sample_column_value) { 'value1' }

      before do
        record.update(sample_column: sample_column_value)
      end

      it 'is valid' do
        expect(record).to be_valid
      end
    end

    context 'when the accessor value is not in the list of definitions' do
      let(:sample_column_value) { 'value3' }

      before do
        record.update(sample_column: sample_column_value)
      end

      it 'is not valid' do
        expect(record).to be_invalid
      end
    end
  end
end
