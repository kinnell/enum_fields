# frozen_string_literal: true

RSpec.describe EnumFields::Base, "Polymorphic Columns" do
  let(:test_model_class) do
    Class.new(MockActiveRecord::Base) do
      include EnumFields

      def self.name
        "PolymorphicTestModel"
      end
    end
  end

  let(:definitions) do
    {
      TypeA: {
        value: "TypeA",
        label: "Type A",
        priority: 1,
      },
      TypeB: {
        value: "TypeB",
        label: "Type B",
        priority: 2,
      },
    }
  end

  let(:type_a_class) do
    Class.new do
      def self.name
        "TypeA"
      end

      def id
        1
      end
    end
  end

  let(:type_b_class) do
    Class.new do
      def self.name
        "TypeB"
      end

      def id
        2
      end
    end
  end

  let(:invalid_type_class) do
    Class.new do
      def self.name
        "InvalidType"
      end

      def id
        99
      end
    end
  end

  let(:association_options) { { polymorphic: true } }
  let(:record_type_options) { {} }
  let(:current_metadata) { definitions.values.first }
  let(:current_value) { current_metadata[:value] }

  before do
    stub_const("PolymorphicTestModel", test_model_class)
    stub_const("TypeA", type_a_class)
    stub_const("TypeB", type_b_class)
    stub_const("InvalidType", invalid_type_class)
    PolymorphicTestModel.belongs_to(:record, association_options)
    PolymorphicTestModel.enum_field(:record_type, definitions, record_type_options)
  end

  describe "Model.<accessor>s" do
    let(:output) { PolymorphicTestModel.record_types }

    it "returns definitions keyed independently from their stored values" do
      expect(output).to match(definitions)
    end
  end

  describe "Model.<accessor>s_count" do
    let(:output) { PolymorphicTestModel.record_types_count }

    it "returns the number of polymorphic definitions" do
      expect(output).to eq(definitions.size)
    end
  end

  describe "Model.<accessor>_values" do
    let(:output) { PolymorphicTestModel.record_type_values }

    it "returns the stored polymorphic type values" do
      expect(output).to match_array(definitions.values.pluck(:value))
    end
  end

  describe "Model.<accessor>_options" do
    let(:output) { PolymorphicTestModel.record_type_options }
    let(:expected_options) { definitions.values.map { |metadata| [metadata[:label], metadata[:value]] } }

    it "returns labels paired with stored polymorphic type values" do
      expect(output).to eq(expected_options)
    end
  end

  describe "Model.<key>_<accessor>_value" do
    let(:output) do
      definitions.keys.to_h { |key| [key, PolymorphicTestModel.public_send("#{key}_record_type_value")] }
    end
    let(:expected_output) { definitions.transform_values { |metadata| metadata[:value] } }

    it "returns the stored value for each definition" do
      expect(output).to eq(expected_output)
    end
  end

  describe "Instance.<accessor>_metadata" do
    let(:record) { PolymorphicTestModel.new(record_type: current_value) }
    let(:output) { record.record_type_metadata }

    it "returns metadata by the stored polymorphic type value" do
      expect(output).to match(current_metadata)
    end
  end

  describe "Instance.<accessor>_value" do
    let(:record) { PolymorphicTestModel.new(record_type: current_value) }
    let(:output) { record.record_type_value }

    it "returns the stored polymorphic type value" do
      expect(output).to eq(current_value)
    end
  end

  describe "Instance.<accessor>_label" do
    let(:record) { PolymorphicTestModel.new(record_type: current_value) }
    let(:output) { record.record_type_label }

    it "returns the label for the stored polymorphic type value" do
      expect(output).to eq(current_metadata[:label])
    end
  end

  describe "Instance.<accessor>_<property>" do
    let(:record) { PolymorphicTestModel.new(record_type: current_value) }
    let(:output) { record.record_type_priority }

    it "returns an additional property by the stored polymorphic type value" do
      expect(output).to eq(current_metadata[:priority])
    end
  end

  describe "Instance.<key>_<accessor>?" do
    let(:record) { PolymorphicTestModel.new(record_type: current_value) }
    let(:output) do
      definitions.keys.to_h { |key| [key, record.public_send("#{key}_record_type?")] }
    end
    let(:expected_output) do
      definitions.transform_values { |metadata| record.record_type == metadata[:value] }
    end

    it "returns whether the stored value matches each definition" do
      expect(output).to eq(expected_output)
    end
  end

  describe "Model.<key>_<accessor>" do
    let(:scope_queries) do
      definitions.map do |key, metadata|
        [PolymorphicTestModel.public_send("#{key}_record_type").to_sql, metadata[:value]]
      end
    end

    it "queries the accessor with the stored value for each definition" do
      expect(scope_queries).to all(satisfy { |sql, value| sql.include?("\"record_type\" = '#{value}'") })
    end
  end

  describe "Validating polymorphic Instance.<accessor>" do
    context "when the assigned association type is in the list of definitions" do
      let(:record) { PolymorphicTestModel.new }
      let(:association) { TypeA.new }

      before do
        record.record = association
        record.valid?
      end

      it "sets the accessor from the association class name" do
        expect(record.record_type).to eq("TypeA")
      end

      it "returns the value from the assigned association type" do
        expect(record.record_type_value).to eq("TypeA")
      end

      it "returns the label from the assigned association type" do
        expect(record.record_type_label).to eq("Type A")
      end

      it "returns metadata from the assigned association type" do
        expect(record.record_type_metadata).to match(definitions[:TypeA])
      end

      it "returns true for the assigned association type" do
        expect(record.TypeA_record_type?).to be true
      end

      it "returns false for a different association type" do
        expect(record.TypeB_record_type?).to be false
      end

      it "is valid" do
        expect(record).to be_valid
      end

      it "does not add an error on :record" do
        expect(record.errors[:record]).to be_empty
      end
    end

    context "when the assigned association type is not in the list of definitions" do
      let(:record) { PolymorphicTestModel.new }
      let(:association) { InvalidType.new }

      before do
        record.record = association
        record.valid?
      end

      it "is not valid" do
        expect(record).to be_invalid
      end

      it "adds an error on :record" do
        expect(record.errors[:record]).to include("must be one of: TypeA, TypeB")
      end
    end

    context "when Instance.<accessor> is in the list of definitions" do
      let(:record) { PolymorphicTestModel.new(record_type: "TypeA", record_id: 1) }

      before { record.valid? }

      it "is valid" do
        expect(record).to be_valid
      end

      it "does not add an error on the accessor" do
        expect(record.errors[:record_type]).to be_empty
      end
    end

    context "when Instance.<accessor> is not in the list of definitions" do
      let(:record) { PolymorphicTestModel.new(record_type: "InvalidType", record_id: 99) }

      before { record.valid? }

      it "is not valid" do
        expect(record).to be_invalid
      end

      it "adds an error on the accessor" do
        expect(record.errors[:record_type]).to include("must be one of: TypeA, TypeB")
      end
    end

    context "when Instance.<accessor> is nil for a required association" do
      let(:record) { PolymorphicTestModel.new(record_type: nil) }

      before { record.valid? }

      it "is not valid" do
        expect(record).to be_invalid
      end

      it "adds an error on the accessor" do
        expect(record.errors[:record_type]).to include("must be one of: TypeA, TypeB")
      end
    end
  end

  describe "Handling :nullable option for a polymorphic column" do
    let(:record) { PolymorphicTestModel.new(record_type: nil) }

    context "when the association is optional and :nullable is not specified" do
      let(:association_options) { { polymorphic: true, optional: true } }

      before { record.valid? }

      it "is valid" do
        expect(record).to be_valid
      end

      it "does not add an error on the accessor" do
        expect(record.errors[:record_type]).to be_empty
      end
    end

    context "when the association is optional and Instance.<accessor> is valid" do
      let(:association_options) { { polymorphic: true, optional: true } }
      let(:record) { PolymorphicTestModel.new(record_type: "TypeA") }

      before { record.valid? }

      it "is valid" do
        expect(record).to be_valid
      end

      it "does not add an error on the accessor" do
        expect(record.errors[:record_type]).to be_empty
      end
    end

    context "when the association is optional and Instance.<accessor> is invalid" do
      let(:association_options) { { polymorphic: true, optional: true } }
      let(:record) { PolymorphicTestModel.new(record_type: "InvalidType") }

      before { record.valid? }

      it "is not valid" do
        expect(record).to be_invalid
      end

      it "adds an error on the accessor" do
        expect(record.errors[:record_type]).to include("must be one of: TypeA, TypeB")
      end
    end

    context "when the association is required and :nullable is true" do
      let(:record_type_options) { { nullable: true } }

      before { record.valid? }

      it "is valid" do
        expect(record).to be_valid
      end

      it "does not add an error on the accessor" do
        expect(record.errors[:record_type]).to be_empty
      end
    end

    context "when the association is optional and :nullable is false" do
      let(:association_options) { { polymorphic: true, optional: true } }
      let(:record_type_options) { { nullable: false } }

      before { record.valid? }

      it "is not valid" do
        expect(record).to be_invalid
      end

      it "adds an error on the accessor" do
        expect(record.errors[:record_type]).to include("must be one of: TypeA, TypeB")
      end
    end
  end

  describe "Handling :validatable option for a polymorphic column" do
    context "when :validatable is false" do
      let(:record_type_options) { { validatable: false } }
      let(:record) { PolymorphicTestModel.new(record_type: "AnythingGoes") }

      before { record.valid? }

      it "is valid" do
        expect(record).to be_valid
      end

      it "does not add an error on the accessor" do
        expect(record.errors[:record_type]).to be_empty
      end
    end
  end

  describe "Validating a non-polymorphic Instance.<accessor>" do
    let(:status_definitions) do
      {
        active: {
          value: "active",
          label: "Active",
        },
        inactive: {
          value: "inactive",
          label: "Inactive",
        },
      }
    end
    let(:record) do
      PolymorphicTestModel.new({
        status: accessor_value,
        record_type: definitions.values.first[:value],
      })
    end

    before do
      PolymorphicTestModel.enum_field(:status, status_definitions)
    end

    context "when Instance.<accessor> is valid" do
      let(:accessor_value) { status_definitions.values.first[:value] }

      before { record.valid? }

      it "is valid" do
        expect(record).to be_valid
      end

      it "does not add an error on the accessor" do
        expect(record.errors[:status]).to be_empty
      end
    end

    context "when Instance.<accessor> is invalid" do
      let(:accessor_value) { "invalid" }

      before { record.valid? }

      it "is not valid" do
        expect(record).to be_invalid
      end

      it "adds an error on the accessor" do
        expect(record.errors[:status]).not_to be_empty
      end
    end
  end

  describe "Handling definition keys that differ from stored values" do
    let(:definitions) do
      {
        type_a: {
          value: "TypeA",
          label: "Type A",
          priority: 1,
        },
        type_b: {
          value: "TypeB",
          label: "Type B",
          priority: 2,
        },
      }
    end
    let(:current_metadata) { definitions.values.first }
    let(:record) { PolymorphicTestModel.new(record_type: current_metadata[:value]) }

    describe "Model.<accessor>s" do
      let(:output) { PolymorphicTestModel.record_types }

      it "returns definitions keyed independently from their stored values" do
        expect(output).to match(definitions)
      end
    end

    describe "Model.<accessor>_values" do
      let(:output) { PolymorphicTestModel.record_type_values }

      it "returns the stored values" do
        expect(output).to match_array(definitions.values.pluck(:value))
      end
    end

    describe "Model.<accessor>_options" do
      let(:output) { PolymorphicTestModel.record_type_options }
      let(:expected_options) { definitions.values.map { |metadata| [metadata[:label], metadata[:value]] } }

      it "returns labels paired with stored values" do
        expect(output).to match_array(expected_options)
      end
    end

    describe "Instance.<accessor>_metadata" do
      let(:output) { record.record_type_metadata }

      it "returns metadata by the stored value" do
        expect(output).to match(current_metadata)
      end
    end

    describe "Instance.<accessor>_value" do
      let(:output) { record.record_type_value }

      it "returns the stored value" do
        expect(output).to eq(current_metadata[:value])
      end
    end

    describe "Instance.<accessor>_<property>" do
      let(:properties) { current_metadata.except(:value) }
      let(:output) do
        properties.keys.to_h { |property| [property, record.public_send("record_type_#{property}")] }
      end

      it "returns each additional property by the stored value" do
        expect(output).to eq(properties)
      end
    end

    describe "Instance.<key>_<accessor>?" do
      let(:output) do
        definitions.keys.to_h { |key| [key, record.public_send("#{key}_record_type?")] }
      end
      let(:expected_output) do
        definitions.transform_values { |metadata| record.record_type == metadata[:value] }
      end

      it "returns whether the stored value matches each key" do
        expect(output).to eq(expected_output)
      end
    end
  end

  describe "Handling :column option for a polymorphic column" do
    let(:record) { PolymorphicTestModel.new(taggable_type: "TypeA", record_type: current_value) }

    before do
      PolymorphicTestModel.belongs_to(:taggable, polymorphic: true)
      PolymorphicTestModel.enum_field(:tag_kind, definitions, column: :taggable_type)
    end

    describe "Model.<accessor>s" do
      let(:output) { PolymorphicTestModel.tag_kinds }

      it "returns the definitions for the accessor" do
        expect(output).to match(definitions)
      end
    end

    describe "Model.<accessor>_values" do
      let(:output) { PolymorphicTestModel.tag_kind_values }

      it "returns the stored values for the accessor" do
        expect(output).to eq(%w[TypeA TypeB])
      end
    end

    describe "Model.<accessor>_options" do
      let(:output) { PolymorphicTestModel.tag_kind_options }

      it "returns labels paired with stored values" do
        expect(output).to eq([
          ["Type A", "TypeA"],
          ["Type B", "TypeB"],
        ])
      end
    end

    describe "Instance.<accessor>" do
      let(:output) { record.tag_kind }

      it "reads from the configured polymorphic type column" do
        expect(output).to eq("TypeA")
      end
    end

    describe "Instance.<accessor>=" do
      let(:new_type) { "TypeB" }

      before { record.tag_kind = new_type }

      it "writes to the configured polymorphic type column" do
        expect(record.taggable_type).to eq(new_type)
      end
    end

    describe "Instance.<accessor>_metadata" do
      let(:output) { record.tag_kind_metadata }

      it "returns metadata from the configured polymorphic type column" do
        expect(output).to match(definitions[:TypeA])
      end
    end

    describe "Instance.<accessor>_<property>" do
      it "returns the label from the configured polymorphic type column" do
        expect(record.tag_kind_label).to eq("Type A")
      end

      it "returns the value from the configured polymorphic type column" do
        expect(record.tag_kind_value).to eq("TypeA")
      end
    end

    describe "Instance.<key>_<accessor>?" do
      it "returns true for the configured polymorphic type" do
        expect(record.TypeA_tag_kind?).to be true
      end

      it "returns false for a different polymorphic type" do
        expect(record.TypeB_tag_kind?).to be false
      end
    end

    describe "Model.<key>_<accessor>" do
      let(:scope_queries) do
        definitions.map do |key, metadata|
          [PolymorphicTestModel.public_send("#{key}_tag_kind").to_sql, metadata[:value]]
        end
      end

      it "queries the configured polymorphic type column for each definition" do
        expect(scope_queries).to all(satisfy { |sql, value| sql.include?("\"taggable_type\" = '#{value}'") })
      end
    end

    describe "Validating polymorphic Instance.<accessor>" do
      context "when the configured column value is in the list of definitions" do
        before { record.valid? }

        it "is valid" do
          expect(record).to be_valid
        end

        it "does not add an error on the configured column" do
          expect(record.errors[:taggable_type]).to be_empty
        end
      end

      context "when the configured column value is not in the list of definitions" do
        let(:record) { PolymorphicTestModel.new(taggable_type: "InvalidType", record_type: current_value) }

        before { record.valid? }

        it "is not valid" do
          expect(record).to be_invalid
        end

        it "adds an error on the configured column" do
          expect(record.errors[:taggable_type]).to include("must be one of: TypeA, TypeB")
        end
      end
    end
  end
end
