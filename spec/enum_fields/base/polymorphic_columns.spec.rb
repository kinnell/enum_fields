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
      TypeA: { value: "TypeA", label: "Type A" },
      TypeB: { value: "TypeB", label: "Type B" },
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

  before do
    stub_const("PolymorphicTestModel", test_model_class)
    stub_const("TypeA", type_a_class)
    stub_const("TypeB", type_b_class)
    stub_const("InvalidType", invalid_type_class)
  end

  describe "polymorphic validation" do
    let(:record) { PolymorphicTestModel.new(record_type: "TypeA") }

    before do
      PolymorphicTestModel.belongs_to(:record, polymorphic: true)
      PolymorphicTestModel.enum_field(:record_type, definitions)
    end

    it "uses custom validation instead of standard inclusion" do
      expect(PolymorphicTestModel.validations[:record_type]).to be_nil
      expect(PolymorphicTestModel.custom_validations).not_to be_empty
    end

    it "defines the enum accessors" do
      expect(PolymorphicTestModel).to respond_to(:record_types)
      expect(PolymorphicTestModel).to respond_to(:record_type_values)
    end

    it "defines inquiry methods" do
      expect(record).to respond_to(:TypeA_record_type?)
      expect(record).to respond_to(:TypeB_record_type?)
    end

    it "defines property methods" do
      expect(record).to respond_to(:record_type_label)
      expect(record).to respond_to(:record_type_value)
    end

    it "has correct property values" do
      expect(record.record_type_label).to eq("Type A")
      expect(record.record_type_value).to eq("TypeA")
    end

    it "defines metadata method" do
      expect(record).to respond_to(:record_type_metadata)
      expect(record.record_type_metadata).to include("value" => "TypeA", "label" => "Type A")
    end

    it "defines scopes" do
      expect(PolymorphicTestModel).to respond_to(:TypeA_record_type)
      expect(PolymorphicTestModel).to respond_to(:TypeB_record_type)
    end

    describe "with association object (Model.new(record: obj))" do
      context "when association type is valid" do
        let(:record) { PolymorphicTestModel.new.tap { |r| r.record = TypeA.new } }

        it "is valid" do
          expect(record).to be_valid
        end

        it "sets record_type from association class name" do
          expect(record.record_type).to eq("TypeA")
        end

        it "has correct property values" do
          expect(record.record_type_label).to eq("Type A")
          expect(record.record_type_value).to eq("TypeA")
        end

        it "has correct metadata" do
          expect(record.record_type_metadata).to include("value" => "TypeA", "label" => "Type A")
        end

        it "inquiry methods work after assigning association" do
          expect(record.TypeA_record_type?).to be true
          expect(record.TypeB_record_type?).to be false
        end
      end

      context "when association type is invalid" do
        let(:record) { PolymorphicTestModel.new.tap { |r| r.record = InvalidType.new } }

        it "is not valid" do
          expect(record).not_to be_valid
        end

        it "adds error to association name" do
          record.valid?
          expect(record.errors[:record]).to include(a_string_matching(%r{must be one of}))
        end
      end
    end

    describe "with direct column assignment (Model.new(record_type: x, record_id: z))" do
      context "when record_type is valid" do
        let(:record) { PolymorphicTestModel.new(record_type: "TypeA", record_id: 1) }

        it "is valid" do
          expect(record).to be_valid
        end
      end

      context "when record_type is invalid" do
        let(:record) { PolymorphicTestModel.new(record_type: "InvalidType", record_id: 99) }

        it "is not valid" do
          expect(record).not_to be_valid
        end

        it "adds error to column name" do
          record.valid?
          expect(record.errors[:record_type]).to include(a_string_matching(%r{must be one of}))
        end
      end

      context "when record_type is nil" do
        let(:record) { PolymorphicTestModel.new(record_type: nil) }

        it "is valid (allows nil)" do
          expect(record).to be_valid
        end
      end
    end
  end

  describe "non-polymorphic columns" do
    let(:non_polymorphic_definitions) do
      {
        active: { value: "active", label: "Active" },
        inactive: { value: "inactive", label: "Inactive" },
      }
    end

    before do
      PolymorphicTestModel.enum_field(:status, non_polymorphic_definitions)
    end

    it "uses standard inclusion validation" do
      expect(PolymorphicTestModel.validations[:status]).to be_present
    end

    context "when value is valid" do
      let(:record) { PolymorphicTestModel.new(status: "active") }

      it "is valid" do
        expect(record).to be_valid
      end
    end

    context "when value is invalid" do
      let(:record) { PolymorphicTestModel.new(status: "invalid") }

      it "is not valid" do
        expect(record).not_to be_valid
      end
    end
  end

  describe "validate: false option" do
    before do
      PolymorphicTestModel.belongs_to(:record, polymorphic: true)
      PolymorphicTestModel.enum_field(:record_type, definitions, validate: false)
    end

    it "skips all validation" do
      expect(PolymorphicTestModel.validations[:record_type]).to be_nil
      expect(PolymorphicTestModel.custom_validations).to be_empty
    end

    it "allows any value" do
      record = PolymorphicTestModel.new(record_type: "AnythingGoes")
      expect(record).to be_valid
    end
  end

  describe "validate: false on non-polymorphic column" do
    let(:non_polymorphic_definitions) do
      {
        active: { value: "active", label: "Active" },
        inactive: { value: "inactive", label: "Inactive" },
      }
    end

    before do
      PolymorphicTestModel.enum_field(:status, non_polymorphic_definitions, validate: false)
    end

    it "skips validation" do
      expect(PolymorphicTestModel.validations[:status]).to be_nil
    end

    it "allows any value" do
      record = PolymorphicTestModel.new(status: "anything")
      expect(record).to be_valid
    end
  end

  describe "with snake_case definition keys (mismatched from column values)" do
    let(:snake_case_definitions) do
      {
        type_a: { value: "TypeA", label: "Type A", priority: 1 },
        type_b: { value: "TypeB", label: "Type B", priority: 2 },
      }
    end

    before do
      PolymorphicTestModel.belongs_to(:record, polymorphic: true)
      PolymorphicTestModel.enum_field(:record_type, snake_case_definitions)
    end

    it "class methods work" do
      expect(PolymorphicTestModel.record_types.keys).to contain_exactly("type_a", "type_b")
      expect(PolymorphicTestModel.record_type_values).to contain_exactly("TypeA", "TypeB")
    end

    it "property methods work via value lookup when key does not match column value" do
      record = PolymorphicTestModel.new(record_type: "TypeA")
      expect(record.record_type_label).to eq("Type A")
      expect(record.record_type_value).to eq("TypeA")
      expect(record.record_type_priority).to eq(1)
    end

    it "metadata method works via value lookup" do
      record = PolymorphicTestModel.new(record_type: "TypeA")
      expect(record.record_type_metadata).to include("value" => "TypeA", "label" => "Type A", "priority" => 1)
    end

    it "inquiry methods still work (they use value comparison)" do
      record = PolymorphicTestModel.new(record_type: "TypeA")
      expect(record.type_a_record_type?).to be true
      expect(record.type_b_record_type?).to be false
    end
  end

  describe "with column override on polymorphic" do
    before do
      PolymorphicTestModel.belongs_to(:taggable, polymorphic: true)
      PolymorphicTestModel.enum_field(:tag_kind, definitions, column: :taggable_type)
    end

    it "detects polymorphic based on actual column name" do
      expect(PolymorphicTestModel.validations[:taggable_type]).to be_nil
      expect(PolymorphicTestModel.custom_validations).not_to be_empty
    end

    it "defines class methods using accessor name" do
      expect(PolymorphicTestModel).to respond_to(:tag_kinds)
      expect(PolymorphicTestModel).to respond_to(:tag_kind_values)
      expect(PolymorphicTestModel).to respond_to(:tag_kind_options)
    end

    it "defines property methods using accessor name" do
      record = PolymorphicTestModel.new(taggable_type: "TypeA")
      expect(record).to respond_to(:tag_kind_label)
      expect(record).to respond_to(:tag_kind_value)
    end

    it "property methods read from the correct column" do
      record = PolymorphicTestModel.new(taggable_type: "TypeA")
      expect(record.tag_kind_label).to eq("Type A")
      expect(record.tag_kind_value).to eq("TypeA")
    end

    it "defines metadata method using accessor name" do
      record = PolymorphicTestModel.new(taggable_type: "TypeA")
      expect(record).to respond_to(:tag_kind_metadata)
      expect(record.tag_kind_metadata).to include("value" => "TypeA", "label" => "Type A")
    end

    it "defines inquiry methods using accessor name" do
      record = PolymorphicTestModel.new(taggable_type: "TypeA")
      expect(record).to respond_to(:TypeA_tag_kind?)
      expect(record.TypeA_tag_kind?).to be true
    end

    it "defines scopes using accessor name" do
      expect(PolymorphicTestModel).to respond_to(:TypeA_tag_kind)
      expect(PolymorphicTestModel).to respond_to(:TypeB_tag_kind)
    end

    it "defines instance getter for accessor" do
      record = PolymorphicTestModel.new(taggable_type: "TypeA")
      expect(record).to respond_to(:tag_kind)
      expect(record.tag_kind).to eq("TypeA")
    end

    it "defines instance setter for accessor" do
      record = PolymorphicTestModel.new
      expect(record).to respond_to(:tag_kind=)
      record.tag_kind = "TypeB"
      expect(record.taggable_type).to eq("TypeB")
    end
  end
end
