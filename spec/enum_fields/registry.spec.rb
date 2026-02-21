# frozen_string_literal: true

require "spec_helper"

RSpec.describe EnumFields::Registry do
  let(:status_definitions) do
    {
      pending: { value: "pending", label: "Pending" },
      active: { value: "active", label: "Active" },
    }
  end

  let(:role_definitions) do
    {
      admin: { value: "admin", label: "Admin" },
      member: { value: "member", label: "Member" },
    }
  end

  describe ".registry" do
    it "returns a Registry instance" do
      expect(EnumFields.registry).to be_a(described_class)
    end

    it "returns the same instance across calls" do
      expect(EnumFields.registry).to equal(EnumFields.registry)
    end
  end

  describe ".register" do
    let(:model_class) do
      Class.new(MockActiveRecord::Base) do
        include EnumFields

        def self.name
          "User"
        end
      end
    end

    before do
      EnumFields.register(model_class: model_class, accessor: :status, definition: status_definitions)
    end

    it "stores the definition under the snake_case model key" do
      expect(EnumFields.registry[:user]).to be_present
    end

    it "stores the definition under the accessor" do
      expect(EnumFields.registry[:user][:status]).to match(status_definitions)
    end

    it "supports string key access" do
      expect(EnumFields.registry["user"]).to be_present
    end

    context "with multiple fields on the same model" do
      before do
        EnumFields.register(model_class: model_class, accessor: :role, definition: role_definitions)
      end

      it "stores both fields under the same model key" do
        expect(EnumFields.registry[:user][:status]).to match(status_definitions)
        expect(EnumFields.registry[:user][:role]).to match(role_definitions)
      end
    end

    context "with a multi-word model name" do
      let(:model_class) do
        Class.new(MockActiveRecord::Base) do
          include EnumFields

          def self.name
            "UserNotification"
          end
        end
      end

      before do
        EnumFields.register(model_class: model_class, accessor: :status, definition: status_definitions)
      end

      it "uses snake_case for the key" do
        expect(EnumFields.registry[:user_notification]).to be_present
      end
    end

    context "with a namespaced model" do
      let(:model_class) do
        Class.new(MockActiveRecord::Base) do
          include EnumFields

          def self.name
            "Admin::User"
          end
        end
      end

      before do
        EnumFields.register(model_class: model_class, accessor: :status, definition: status_definitions)
      end

      it "uses the underscored namespace path as key" do
        expect(EnumFields.registry["admin/user"]).to be_present
      end
    end
  end

  describe "#to_h" do
    let(:user_class) do
      Class.new(MockActiveRecord::Base) do
        include EnumFields

        def self.name
          "User"
        end
      end
    end

    let(:order_class) do
      Class.new(MockActiveRecord::Base) do
        include EnumFields

        def self.name
          "Order"
        end
      end
    end

    context "with nothing registered" do
      it "returns an empty hash" do
        expect(EnumFields.registry.to_h).to eq({})
      end
    end

    context "with a single field on one model" do
      before do
        EnumFields.register(model_class: user_class, accessor: :status, definition: status_definitions)
      end

      it "returns the model key with its field" do
        expect(EnumFields.registry.to_h).to match({
          "user" => { "status" => status_definitions },
        })
      end
    end

    context "with two fields on the same model" do
      before do
        EnumFields.register(model_class: user_class, accessor: :status, definition: status_definitions)
        EnumFields.register(model_class: user_class, accessor: :role, definition: role_definitions)
      end

      it "returns the model key with both fields" do
        expect(EnumFields.registry.to_h).to match({
          "user" => {
            "status" => status_definitions,
            "role" => role_definitions,
          },
        })
      end
    end

    context "with multiple models" do
      let(:order_status_definitions) do
        {
          pending: { value: "pending", label: "Pending" },
          shipped: { value: "shipped", label: "Shipped" },
        }
      end

      before do
        EnumFields.register(model_class: user_class, accessor: :status, definition: status_definitions)
        EnumFields.register(model_class: user_class, accessor: :role, definition: role_definitions)
        EnumFields.register(model_class: order_class, accessor: :status, definition: order_status_definitions)
      end

      it "returns all models with their fields" do
        expect(EnumFields.registry.to_h).to match({
          "user" => {
            "status" => status_definitions,
            "role" => role_definitions,
          },
          "order" => {
            "status" => order_status_definitions,
          },
        })
      end
    end
  end

  describe "integration with enum_field" do
    let(:user_class) do
      Class.new(MockActiveRecord::Base) do
        include EnumFields

        def self.name
          "User"
        end
      end
    end

    let(:order_class) do
      Class.new(MockActiveRecord::Base) do
        include EnumFields

        def self.name
          "Order"
        end
      end
    end

    before do
      stub_const("User", user_class)
      stub_const("Order", order_class)

      User.enum_field :status, status_definitions
      User.enum_field :role, role_definitions
      Order.enum_field :status, { pending: { value: "pending" }, shipped: { value: "shipped" } }
    end

    it "registers fields when enum_field is called" do
      expect(EnumFields.registry[:user]).to be_present
      expect(EnumFields.registry[:order]).to be_present
    end

    it "contains all fields for User" do
      expect(EnumFields.registry[:user].keys).to contain_exactly("status", "role")
    end

    it "contains all fields for Order" do
      expect(EnumFields.registry[:order].keys).to contain_exactly("status")
    end

    it "stores the correct definition data" do
      expect(EnumFields.registry[:user][:status][:pending][:value]).to eq("pending")
      expect(EnumFields.registry[:user][:status][:active][:value]).to eq("active")
    end

    it "lists all registered model keys" do
      expect(EnumFields.registry.keys).to contain_exactly("user", "order")
    end
  end

  describe ".clear_registry!" do
    let(:model_class) do
      Class.new(MockActiveRecord::Base) do
        include EnumFields

        def self.name
          "User"
        end
      end
    end

    before do
      EnumFields.register(model_class: model_class, accessor: :status, definition: status_definitions)
    end

    it "clears the registry via the module method" do
      expect(EnumFields.registry.keys).to be_present

      EnumFields.clear_registry!

      expect(EnumFields.registry.keys).to be_empty
    end

    it "returns a fresh Registry instance after clearing" do
      old_registry = EnumFields.registry

      EnumFields.clear_registry!

      expect(EnumFields.registry).not_to equal(old_registry)
      expect(EnumFields.registry).to be_a(described_class)
    end
  end

  describe ".register with an anonymous model class" do
    let(:model_class) do
      Class.new(MockActiveRecord::Base) do
        include EnumFields
      end
    end

    it "falls back to object_id as the key" do
      EnumFields.register(model_class: model_class, accessor: :status, definition: status_definitions)

      expected_key = model_class.object_id.to_s
      expect(EnumFields.registry[expected_key]).to be_present
      expect(EnumFields.registry[expected_key][:status]).to match(status_definitions)
    end
  end
end
