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

  let(:priority_definitions) do
    {
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

  describe "EnumFields.registry" do
    let(:registry1) { EnumFields.registry }
    let(:registry2) { EnumFields.registry }

    it "returns a Registry instance" do
      expect(registry1).to be_a(described_class)
    end

    it "returns the same instance across calls" do
      expect(registry1).to equal(registry2)
    end
  end

  describe "EnumFields.register" do
    let(:registry) { EnumFields.registry }

    context "with :namespace, :accessor, and :definition" do
      before do
        EnumFields.register({
          namespace: :user,
          accessor: :status,
          definition: status_definitions,
        })
      end

      it "stores the definition under its namespace and accessor" do
        expect(registry[:user][:status]).to match(status_definitions)
      end

      it "supports indifferent namespace and accessor access" do
        expect(registry["user"]["status"]).to match(status_definitions)
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
          expect(registry[:user]).to match({
            "status" => status_definitions,
            "role" => role_definitions,
          })
        end
      end
    end

    context "without :namespace" do
      let(:registration) do
        lambda do
          EnumFields.register({
            accessor: :status,
            definition: status_definitions,
          })
        end
      end

      it "raises ArgumentError" do
        expect(&registration).to raise_error(ArgumentError, "namespace is required")
      end
    end

    context "without :accessor" do
      let(:registration) do
        lambda do
          EnumFields.register({
            namespace: :user,
            definition: status_definitions,
          })
        end
      end

      it "raises ArgumentError" do
        expect(&registration).to raise_error(ArgumentError, "accessor is required")
      end
    end

    context "without :definition" do
      before do
        EnumFields.register({ namespace: :user, accessor: :status })
      end

      it "defaults definition to an empty hash" do
        expect(registry[:user][:status]).to eq({})
      end
    end

    context "with keyword arguments" do
      before do
        EnumFields.register(namespace: :user, accessor: :role, definition: role_definitions)
      end

      it "stores the definition" do
        expect(registry[:user][:role]).to match(role_definitions)
      end
    end
  end

  describe "#to_h" do
    let(:registry_hash) { EnumFields.registry.to_h }

    context "with nothing registered" do
      it "returns an empty hash" do
        expect(registry_hash).to eq({})
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
        expect(registry_hash).to match({
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
        expect(registry_hash).to match({
          "user" => {
            "status" => status_definitions,
            "role" => role_definitions,
          },
        })
      end
    end

    context "with multiple namespaces" do
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
        expect(registry_hash).to match({
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

  describe "Model.enum_field" do
    context "with named model classes" do
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

      let(:registered_fields) { EnumFields.registry.to_h }

      before do
        user_class.enum_field :status, status_definitions
        user_class.enum_field :role, role_definitions
        order_class.enum_field :status, order_status_definitions
      end

      it "registers each model field under the model namespace" do
        expect(registered_fields).to match({
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

    context "with an anonymous model class" do
      let(:model_class) do
        Class.new(MockActiveRecord::Base) do
          include EnumFields
        end
      end

      let(:anonymous_namespace) { model_class.object_id.to_s }
      let(:anonymous_definition) { EnumFields.registry[anonymous_namespace][:status] }

      before do
        model_class.enum_field :status, status_definitions
      end

      it "registers the field under an object identifier namespace" do
        expect(anonymous_definition).to match(status_definitions)
      end
    end
  end

  describe "EnumFields.clear_registry!" do
    let!(:registry_before_clearing) { EnumFields.registry }
    let(:registry_after_clearing) { EnumFields.registry }

    before do
      EnumFields.register({
        namespace: :user,
        accessor: :status,
        definition: status_definitions,
      })
      EnumFields.clear_registry!
    end

    it "removes all registered fields" do
      expect(registry_after_clearing).to be_empty
    end

    it "returns a fresh Registry instance after clearing" do
      expect(registry_after_clearing).not_to equal(registry_before_clearing)
    end

    it "returns a Registry instance after clearing" do
      expect(registry_after_clearing).to be_a(described_class)
    end
  end

  describe "EnumFields.namespace" do
    let(:registry_hash) { EnumFields.registry.to_h }

    context "with a single field" do
      before do
        status_definition = status_definitions

        EnumFields.namespace(:basic) do
          enum_field :status, status_definition
        end
      end

      it "registers the field under the given namespace" do
        expect(registry_hash).to match({
          "basic" => {
            "status" => status_definitions,
          },
        })
      end

      it "adds the namespace to the catalog" do
        expect(EnumFields.catalog["basic"]).to eq({
          "status" => status_definitions.values.map(&:stringify_keys),
        })
      end
    end

    context "with multiple fields" do
      before do
        status_definition = status_definitions
        priority_definition = priority_definitions

        EnumFields.namespace(:basic) do
          enum_field :status, status_definition
          enum_field :priority, priority_definition
        end
      end

      it "registers all fields under the same namespace" do
        expect(registry_hash["basic"]).to match({
          "status" => status_definitions,
          "priority" => priority_definitions,
        })
      end
    end

    context "with multiple namespace blocks" do
      before do
        status_definition = status_definitions

        EnumFields.namespace(:basic) do
          enum_field :status, status_definition
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
        expect(registry_hash).to match({
          "basic" => {
            "status" => status_definitions,
          },
          "settings" => {
            "page_size" => {
              "50" => {
                value: 50,
                label: "50",
              },
              "100" => {
                value: 100,
                label: "100",
              },
            },
          },
        })
      end
    end

    context "when called multiple times for the same namespace" do
      before do
        status_definition = status_definitions
        priority_definition = priority_definitions

        EnumFields.namespace(:basic) do
          enum_field :status, status_definition
        end

        EnumFields.namespace(:basic) do
          enum_field :priority, priority_definition
        end
      end

      it "merges fields into the same namespace" do
        expect(registry_hash["basic"]).to match({
          "status" => status_definitions,
          "priority" => priority_definitions,
        })
      end
    end
  end

  describe "EnumFields.catalog" do
    let(:catalog) { EnumFields.catalog }

    context "with nothing registered" do
      it "returns an empty hash" do
        expect(catalog).to eq({})
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
        expect(catalog).to eq({
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
        expect(catalog).to eq({
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
        expect(catalog.keys).to eq(%w[order user])
      end

      it "preserves field registration order within namespaces" do
        expect(catalog["user"].keys).to eq(%w[status role])
      end
    end

    context "with an additional namespace that sorts first" do
      before do
        EnumFields.register({
          namespace: :user,
          accessor: :status,
          definition: status_definitions,
        })
        EnumFields.register({
          namespace: :basic,
          accessor: :priority,
          definition: priority_definitions,
        })
      end

      it "sorts namespaces alphabetically" do
        expect(catalog.keys).to eq(%w[basic user])
      end

      it "returns full metadata for the additional namespace" do
        expect(catalog["basic"]).to eq({
          "priority" => priority_definitions.values.map(&:stringify_keys),
        })
      end
    end
  end
end
