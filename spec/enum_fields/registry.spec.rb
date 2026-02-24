# frozen_string_literal: true

require "spec_helper"

RSpec.describe EnumFields::Registry do
  let(:status_definitions) do
    {
      pending: {
        value: "pending",
        label: "Pending",
      },
      active: {
        value: "active",
        label: "Active",
      },
    }
  end

  let(:role_definitions) do
    {
      admin: {
        value: "admin",
        label: "Admin",
      },
      member: {
        value: "member",
        label: "Member",
      },
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
    before do
      EnumFields.register({
        namespace: :user,
        accessor: :status,
        definition: status_definitions,
      })
    end

    it "stores the definition under the namespace" do
      expect(EnumFields.registry[:user]).to be_present
    end

    it "stores the definition under the accessor" do
      expect(EnumFields.registry[:user][:status]).to match(status_definitions)
    end

    it "supports string key access" do
      expect(EnumFields.registry["user"]).to be_present
    end

    context "with multiple fields on the same namespace" do
      before do
        EnumFields.register({
          namespace: :user,
          accessor: :role,
          definition: role_definitions,
        })
      end

      it "stores both fields under the same namespace" do
        expect(EnumFields.registry[:user][:status]).to match(status_definitions)
        expect(EnumFields.registry[:user][:role]).to match(role_definitions)
      end
    end

    context "without namespace" do
      it "raises ArgumentError" do
        expect { EnumFields.register({ accessor: :status, definition: status_definitions }) }.to raise_error(ArgumentError, "namespace is required")
      end
    end

    context "without accessor" do
      it "raises ArgumentError" do
        expect { EnumFields.register({ namespace: :user, definition: status_definitions }) }.to raise_error(ArgumentError, "accessor is required")
      end
    end

    context "without definition" do
      before do
        EnumFields.register({ namespace: :user, accessor: :status })
      end

      it "defaults definition to an empty hash" do
        expect(EnumFields.registry[:user][:status]).to eq({})
      end
    end

    context "with keyword arguments" do
      before do
        EnumFields.register(namespace: :user, accessor: :role, definition: role_definitions)
      end

      it "works the same as the hash format" do
        expect(EnumFields.registry[:user][:role]).to match(role_definitions)
      end
    end
  end

  describe "#to_h" do
    context "with nothing registered" do
      it "returns an empty hash" do
        expect(EnumFields.registry.to_h).to eq({})
      end
    end

    context "with a single field on one namespace" do
      before do
        EnumFields.register({
          namespace: :user,
          accessor: :status,
          definition: status_definitions,
        })
      end

      it "returns the namespace with its field" do
        expect(EnumFields.registry.to_h).to match({
          "user" => { "status" => status_definitions },
        })
      end
    end

    context "with two fields on the same namespace" do
      before do
        EnumFields.register({
          namespace: :user,
          accessor: :status,
          definition: status_definitions,
        })
        EnumFields.register({
          namespace: :user,
          accessor: :role,
          definition: role_definitions,
        })
      end

      it "returns the namespace with both fields" do
        expect(EnumFields.registry.to_h).to match({
          "user" => {
            "status" => status_definitions,
            "role" => role_definitions,
          },
        })
      end
    end

    context "with multiple namespaces" do
      let(:order_status_definitions) do
        {
          pending: {
            value: "pending",
            label: "Pending",
          },
          shipped: {
            value: "shipped",
            label: "Shipped",
          },
        }
      end

      before do
        EnumFields.register({
          namespace: :user,
          accessor: :status,
          definition: status_definitions,
        })

        EnumFields.register({
          namespace: :user,
          accessor: :role,
          definition: role_definitions,
        })

        EnumFields.register({
          namespace: :order,
          accessor: :status,
          definition: order_status_definitions,
        })
      end

      it "returns all namespaces with their fields" do
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
      Order.enum_field :status, {
        pending: {
          value: "pending",
        },
        shipped: {
          value: "shipped",
        },
      }
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

    it "lists all registered namespace keys" do
      expect(EnumFields.registry.keys).to contain_exactly("user", "order")
    end
  end

  describe ".clear_registry!" do
    before do
      EnumFields.register({
        namespace: :user,
        accessor: :status,
        definition: status_definitions,
      })
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

    it "derives namespace from object_id for anonymous classes" do
      EnumFields::EnumField.define(
        model_class: model_class,
        accessor: :status,
        definition: status_definitions,
        options: {}
      )

      expected_namespace = model_class.object_id.to_s
      expect(EnumFields.registry[expected_namespace]).to be_present
      expect(EnumFields.registry[expected_namespace][:status]).to be_present
    end
  end

  describe ".namespace" do
    context "with a single field" do
      before do
        EnumFields.namespace(:basic) do
          enum_field :status, {
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
      end

      it "registers the field under the given namespace" do
        expect(EnumFields.registry[:basic][:status]).to be_present
      end

      it "stores the correct definition data" do
        expect(EnumFields.registry[:basic][:status][:active][:value]).to eq("active")
      end
    end

    context "with multiple fields" do
      before do
        EnumFields.namespace(:basic) do
          enum_field :status, {
            active: {
              value: "active",
              label: "Active",
            },
            inactive: {
              value: "inactive",
              label: "Inactive",
            },
          }
          enum_field :priority, {
            low: {
              value: "low",
              label: "Low",
            },
            high: {
              value: "high",
              label: "High",
            },
          }
        end
      end

      it "registers all fields under the same namespace" do
        expect(EnumFields.registry[:basic].keys).to contain_exactly("status", "priority")
      end
    end

    context "with multiple namespace blocks" do
      before do
        EnumFields.namespace(:basic) do
          enum_field :status, {
            active: {
              value: "active",
              label: "Active",
            },
          }
        end

        EnumFields.namespace(:settings) do
          enum_field :page_size, {
            "50" => {
              value: 50,
              label: "50",
            },
            "100" => {
              value: 100,
              label: "100",
            },
          }
        end
      end

      it "registers fields under separate namespaces" do
        expect(EnumFields.registry[:basic][:status]).to be_present
        expect(EnumFields.registry[:settings][:page_size]).to be_present
      end
    end

    context "called multiple times for the same namespace" do
      before do
        EnumFields.namespace(:basic) do
          enum_field :status, {
            active: {
              value: "active",
              label: "Active",
            },
          }
        end

        EnumFields.namespace(:basic) do
          enum_field :priority, {
            low: {
              value: "low",
              label: "Low",
            },
          }
        end
      end

      it "merges fields into the same namespace" do
        expect(EnumFields.registry[:basic].keys).to contain_exactly("status", "priority")
      end
    end

    it "appears in the catalog" do
      EnumFields.namespace(:basic) do
        enum_field :priority, {
          low: {
            value: "low",
            label: "Low",
          },
          high: {
            value: "high",
            label: "High",
          },
        }
      end

      expect(EnumFields.catalog["basic"]).to eq({
        "priority" => [
          {
            "value" => "low",
            "label" => "Low",
          },
          {
            "value" => "high",
            "label" => "High",
          },
        ],
      })
    end
  end

  describe ".catalog" do
    context "with nothing registered" do
      it "returns an empty hash" do
        expect(EnumFields.catalog).to eq({})
      end
    end

    context "with a single namespace" do
      before do
        EnumFields.register({
          namespace: :user,
          accessor: :status,
          definition: status_definitions,
        })
      end

      it "returns full metadata arrays grouped by namespace and accessor" do
        expect(EnumFields.catalog).to eq({
          "user" => {
            "status" => [
              {
                "value" => "pending",
                "label" => "Pending",
              },
              {
                "value" => "active",
                "label" => "Active",
              },
            ],
          },
        })
      end
    end

    context "with multiple namespaces" do
      let(:order_status_definitions) do
        {
          pending: {
            value: "pending",
            label: "Pending",
          },
          shipped: {
            value: "shipped",
            label: "Shipped",
          },
        }
      end

      before do
        EnumFields.register({
          namespace: :user,
          accessor: :status,
          definition: status_definitions,
        })
        EnumFields.register({
          namespace: :user,
          accessor: :role,
          definition: role_definitions,
        })
        EnumFields.register({
          namespace: :order,
          accessor: :status,
          definition: order_status_definitions,
        })
      end

      it "returns metadata for all namespaces" do
        expect(EnumFields.catalog).to eq({
          "order" => {
            "status" => [
              {
                "value" => "pending",
                "label" => "Pending",
              },
              {
                "value" => "shipped",
                "label" => "Shipped",
              },
            ],
          },
          "user" => {
            "status" => [
              {
                "value" => "pending",
                "label" => "Pending",
              },
              {
                "value" => "active",
                "label" => "Active",
              },
            ],
            "role" => [
              {
                "value" => "admin",
                "label" => "Admin",
              },
              {
                "value" => "member",
                "label" => "Member",
              },
            ],
          },
        })
      end

      it "sorts namespaces alphabetically" do
        expect(EnumFields.catalog.keys).to eq(%w[order user])
      end

      it "preserves field registration order within namespaces" do
        expect(EnumFields.catalog["user"].keys).to eq(%w[status role])
      end
    end

    context "with a :basic namespace" do
      before do
        EnumFields.register({
          namespace: :basic,
          accessor: :priority,
          definition: {
            low: {
              value: "low",
              label: "Low",
            },
            high: {
              value: "high",
              label: "High",
            },
          },
        })

        EnumFields.register({
          namespace: :user,
          accessor: :status,
          definition: status_definitions,
        })
      end

      it "sorts :basic alongside other namespaces" do
        expect(EnumFields.catalog.keys).to eq(%w[basic user])
      end

      it "returns metadata for the :basic namespace" do
        expect(EnumFields.catalog["basic"]).to eq({
          "priority" => [
            {
              "value" => "low",
              "label" => "Low",
            },
            {
              "value" => "high",
              "label" => "High",
            },
          ],
        })
      end
    end
  end
end
