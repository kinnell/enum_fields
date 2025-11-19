# frozen_string_literal: true

RSpec.describe EnumFields::Base do
  include_context 'with TestModel'

  let(:definitions) do
    {
      value1: {
        value: 'value1',
        label: 'Value 1',
        icon: 'icon1',
        color: 'color1',
        tooltip: 'Tooltip 1',
      },
      value2: {
        value: 'value2',
        label: 'Value 2',
        icon: 'icon2',
        color: 'color2',
        tooltip: 'Tooltip 2',
      },
    }
  end

  let(:another_definitions) do
    {
      value3: {
        value: 'value3',
        label: 'Value 3',
      },
      value4: {
        value: 'value4',
        label: 'Value 4',
      },
    }
  end

  before do
    TestModel.enum_field :sample_column, definitions
    TestModel.enum_field :another_column, another_definitions
  end

  describe 'Model.enum_field_for' do
    context 'when the accessor is defined' do
      let(:accessor) { :sample_column }

      it 'returns the definition' do
        expect(TestModel.enum_field_for(accessor)).to match(definitions)
      end
    end

    context 'when the accessor is not defined' do
      let(:accessor) { :sample_field }

      it 'returns nil' do
        expect(TestModel.enum_field_for(accessor)).to be_nil
      end
    end
  end

  describe 'Model.enum_field?' do
    context 'when the accessor is defined' do
      let(:accessor) { :sample_column }

      it 'returns true' do
        expect(TestModel.enum_field?(accessor)).to be_truthy
      end
    end

    context 'when the accessor is not defined' do
      let(:accessor) { :sample_field }

      it 'returns false' do
        expect(TestModel.enum_field?(accessor)).to be_falsey
      end
    end
  end

  describe 'Model.<accessor>s' do
    it 'defines definitions method on the class' do
      expect(TestModel).to respond_to(:sample_columns)
    end

    it 'returns definitions as a hash' do
      expect(TestModel.sample_columns).to match(definitions)
    end
  end

  describe 'Model.<accessor>s_count' do
    it 'defines definitions count method on the class' do
      expect(TestModel).to respond_to(:sample_columns_count)
    end

    it 'returns the number of definitions' do
      expect(TestModel.sample_columns_count).to eq(definitions.size)
    end
  end

  describe 'Model.<accessor>_values' do
    it 'defines definitions values method on the class' do
      expect(TestModel).to respond_to(:sample_column_values)
    end

    it 'returns the values of the definitions' do
      expect(TestModel.sample_column_values).to eq(%w[value1 value2])
    end
  end

  describe 'Model.<accessor>_options' do
    it 'defines definitions options method on the class' do
      expect(TestModel).to respond_to(:sample_column_options)
    end

    it 'returns the options of the definitions' do
      expect(TestModel.sample_column_options).to match(definitions.map { |key, definition|
        [definition[:label], key.to_s]
      })
    end
  end

  describe 'Instance.enum_fields_metadata' do
    it 'defines enum_fields_metadata method on the instance' do
      expect(record).to respond_to(:enum_fields_metadata)
    end

    it 'returns a HashWithIndifferentAccess' do
      expect(record.enum_fields_metadata).to be_a(HashWithIndifferentAccess)
    end

    it 'returns the metadata of the accessor' do
      expect(record.enum_fields_metadata).to match({
        sample_column: definitions[record.sample_column.to_sym],
        another_column: another_definitions[record.another_column.to_sym],
      })
    end
  end

  describe 'Instance.<accessor>' do
    it 'defines getter method on the instance' do
      expect(record).to respond_to(:sample_column)
    end

    it 'returns the value of the accessor' do
      expect(record.sample_column).to eq(sample_column_value)
    end
  end

  describe 'Instance.<accessor>=' do
    it 'defines setter method on the instance' do
      expect(record).to respond_to(:sample_column=)
    end

    it 'sets the value of the accessor' do
      expect(record.sample_column).to eq(sample_column_value)
    end
  end

  describe 'Instance.<accessor>_metadata' do
    it 'defines metadata method on the instance' do
      expect(record).to respond_to(:sample_column_metadata)
    end

    it 'returns the metadata of the accessor' do
      expect(record.sample_column_metadata).to match(definitions[:value1])
    end
  end

  describe 'Instance.<accessor>_value' do
    it 'defines value method on the instance' do
      expect(record).to respond_to(:sample_column_value)
    end

    it 'returns the value of the accessor' do
      expect(record.sample_column_value).to eq(definitions.dig(:value1, :value))
    end
  end

  describe 'Instance.<accessor>_label' do
    it 'defines label method on the instance' do
      expect(record).to respond_to(:sample_column_label)
    end

    it 'returns the label of the accessor' do
      expect(record.sample_column_label).to eq(definitions.dig(:value1, :label))
    end
  end

  describe 'Instance.<accessor>_icon' do
    it 'defines icon method on the instance' do
      expect(record).to respond_to(:sample_column_icon)
    end

    it 'returns the icon of the accessor' do
      expect(record.sample_column_icon).to eq(definitions.dig(:value1, :icon))
    end
  end

  describe 'Instance.<accessor>_color' do
    it 'defines color method on the instance' do
      expect(record).to respond_to(:sample_column_color)
    end

    it 'returns the color of the accessor' do
      expect(record.sample_column_color).to eq(definitions.dig(:value1, :color))
    end
  end

  describe 'Instance.<accessor>_tooltip' do
    it 'defines tooltip method on the instance' do
      expect(record).to respond_to(:sample_column_tooltip)
    end

    it 'returns the tooltip of the accessor' do
      expect(record.sample_column_tooltip).to eq(definitions.dig(:value1, :tooltip))
    end
  end

  describe 'Instance.<accessor>?' do
    it 'defines inquiry methods on the instance' do
      expect(record).to respond_to(:value1_sample_column?)
      expect(record).to respond_to(:value2_sample_column?)
    end

    it 'returns true if the accessor is value1' do
      expect(record.value1_sample_column?).to be_truthy
      expect(record.value2_sample_column?).to be_falsey
    end
  end

  describe 'Model.<key>_<accessor>' do
    it 'defines scope methods on the class' do
      expect(TestModel).to respond_to(:value1_sample_column)
      expect(TestModel).to respond_to(:value2_sample_column)
    end

    it 'returns the records with the value1 accessor' do
      expect(TestModel.value1_sample_column.to_sql).to match(%r{
        \ASELECT\s+"with_model_test_models_\d+_\d+"\.\*
        \s+FROM\s+"with_model_test_models_\d+_\d+"
        \s+WHERE\s+"with_model_test_models_\d+_\d+"\."sample_column"\s+=\s+'value
      }x)
    end

    it 'returns the records with the value2 accessor' do
      expect(TestModel.value2_sample_column.to_sql).to match(%r{
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
