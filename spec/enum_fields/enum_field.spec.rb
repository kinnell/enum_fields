# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EnumFields::EnumField do
  include_context 'with TestModel'

  let(:definitions) do
    {
      pending: {
        value: 'pending',
        label: 'Pending',
        icon: 'clock',
      },
      active: {
        value: 'active',
        label: 'Active',
        icon: 'check',
      },
    }
  end

  describe '.define' do
    it 'defines methods on the model class' do
      described_class.define(
        model_class: TestModel,
        accessor: :status,
        definition: definitions,
        options: {}
      )

      expect(TestModel).to respond_to(:statuses)
    end

    it 'returns validation result' do
      result = described_class.define(
        model_class: TestModel,
        accessor: :status,
        definition: definitions,
        options: {}
      )

      expect(result).to be_present
    end
  end

  describe '#initialize' do
    subject(:enum_field) do
      described_class.new(
        model_class: TestModel,
        accessor: :status,
        definition: definitions,
        options: options
      )
    end

    context 'without custom column' do
      let(:options) { {} }

      it 'sets accessor as symbol' do
        expect(enum_field.instance_variable_get(:@accessor)).to eq(:status)
      end

      it 'sets column_name same as accessor' do
        expect(enum_field.instance_variable_get(:@column_name)).to eq(:status)
      end

      it 'creates Definition object' do
        definition = enum_field.instance_variable_get(:@definition)
        expect(definition).to be_a(EnumFields::Definition)
      end
    end

    context 'with custom column' do
      let(:options) { { column: :status_type } }

      it 'sets column_name from options' do
        expect(enum_field.instance_variable_get(:@column_name)).to eq(:status_type)
      end

      it 'keeps accessor as provided' do
        expect(enum_field.instance_variable_get(:@accessor)).to eq(:status)
      end
    end
  end

  describe '#define!' do
    before do
      described_class.new(
        model_class: TestModel,
        accessor: :status,
        definition: definitions,
        options: {}
      ).define!
    end

    describe 'storing definition' do
      it 'stores definition data in enum_fields' do
        expect(TestModel.enum_fields[:status]).to be_present
      end

      it 'stores the definition hash' do
        pending_def = TestModel.enum_fields[:status][:pending]
        expect(pending_def[:value]).to eq('pending')
        expect(pending_def[:label]).to eq('Pending')
        expect(pending_def[:icon]).to eq('clock')
      end
    end

    describe 'class methods' do
      it 'defines collection method' do
        expect(TestModel).to respond_to(:statuses)
      end

      it 'defines count method' do
        expect(TestModel).to respond_to(:statuses_count)
      end

      it 'defines values method' do
        expect(TestModel).to respond_to(:status_values)
      end

      it 'defines options method' do
        expect(TestModel).to respond_to(:status_options)
      end

      it 'returns correct values' do
        expect(TestModel.status_values).to contain_exactly('pending', 'active')
      end

      it 'returns correct count' do
        expect(TestModel.statuses_count).to eq(2)
      end

      it 'returns correct options' do
        expect(TestModel.status_options).to match([
          %w[
            Pending
            pending
          ],
          %w[
            Active
            active
          ],
        ])
      end
    end

    describe 'instance methods' do
      let(:record) { TestModel.new(status: 'pending') }

      it 'defines metadata method' do
        expect(record).to respond_to(:status_metadata)
      end

      it 'defines property methods' do
        expect(record).to respond_to(:status_value)
        expect(record).to respond_to(:status_label)
        expect(record).to respond_to(:status_icon)
      end

      it 'defines inquiry methods' do
        expect(record).to respond_to(:pending_status?)
        expect(record).to respond_to(:active_status?)
      end

      it 'returns correct metadata' do
        metadata = record.status_metadata
        expect(metadata[:value]).to eq('pending')
        expect(metadata[:label]).to eq('Pending')
        expect(metadata[:icon]).to eq('clock')
      end

      it 'returns correct property values' do
        expect(record.status_label).to eq('Pending')
        expect(record.status_icon).to eq('clock')
      end

      it 'inquiry methods return correct boolean' do
        expect(record.pending_status?).to be(true)
        expect(record.active_status?).to be(false)
      end
    end

    describe 'scopes' do
      it 'defines scopes for each value' do
        expect(TestModel).to respond_to(:pending_status)
        expect(TestModel).to respond_to(:active_status)
      end
    end

    describe 'validation' do
      let(:record) { TestModel.new(status: 'invalid') }

      it 'validates inclusion' do
        expect(record.valid?).to be(false)
      end

      it 'allows valid values' do
        record.status = 'pending'
        expect(record.valid?).to be(true)
      end

      it 'allows nil' do
        record.status = nil
        expect(record.valid?).to be(true)
      end
    end
  end

  describe 'custom column option' do
    before do
      described_class.new(
        model_class: TestModel,
        accessor: :workflow,
        definition: definitions,
        options: { column: :status }
      ).define!
    end

    describe 'getter and setter' do
      let(:record) { TestModel.new(status: 'pending') }

      it 'defines custom getter' do
        expect(record).to respond_to(:workflow)
      end

      it 'defines custom setter' do
        expect(record).to respond_to(:workflow=)
      end

      it 'getter returns column value' do
        expect(record.workflow).to eq('pending')
      end

      it 'setter updates column value' do
        record.workflow = 'active'
        expect(record.status).to eq('active')
      end
    end

    describe 'metadata methods' do
      let(:record) { TestModel.new(status: 'pending') }

      it 'uses custom column for metadata' do
        metadata = record.workflow_metadata
        expect(metadata[:value]).to eq('pending')
        expect(metadata[:label]).to eq('Pending')
        expect(metadata[:icon]).to eq('clock')
      end

      it 'uses custom column for properties' do
        expect(record.workflow_label).to eq('Pending')
      end
    end

    describe 'inquiry methods' do
      let(:record) { TestModel.new(status: 'active') }

      it 'uses custom column for inquiry' do
        expect(record.pending_workflow?).to be(false)
        expect(record.active_workflow?).to be(true)
      end
    end

    describe 'scopes' do
      it 'uses custom column in scopes' do
        expect(TestModel).to respond_to(:pending_workflow)
        expect(TestModel).to respond_to(:active_workflow)
      end
    end
  end

  describe 'closure variable capture' do
    before do
      described_class.new(
        model_class: TestModel,
        accessor: :priority,
        definition: { low: { value: 'low' }, high: { value: 'high' } },
        options: { column: :priority_level }
      ).define!
    end

    let(:record) { TestModel.new(priority_level: 'low') }

    it 'captures column_name correctly in getter' do
      expect(record.priority).to eq('low')
    end

    it 'captures column_name correctly in setter' do
      record.priority = 'high'
      expect(record.priority_level).to eq('high')
    end

    it 'captures column_name correctly in metadata method' do
      expect(record.priority_metadata[:value]).to eq('low')
    end

    it 'captures column_name correctly in inquiry methods' do
      expect(record.low_priority?).to be(true)
      expect(record.high_priority?).to be(false)
    end
  end

  describe 'with array definition' do
    before do
      described_class.new(
        model_class: TestModel,
        accessor: :role,
        definition: %w[user admin],
        options: {}
      ).define!
    end

    it 'creates proper definitions from array' do
      expect(TestModel.role_values).to contain_exactly('user', 'admin')
    end

    it 'creates inquiry methods' do
      record = TestModel.new(role: 'admin')
      expect(record.admin_role?).to be(true)
    end
  end
end
