# frozen_string_literal: true

module EnumFields
  class Registry < SimpleDelegator
    def initialize
      @store = {}.with_indifferent_access
      super(@store)
    end

    def register(args = {})
      namespace = args.fetch(:namespace) { raise ArgumentError, "namespace is required" }
      accessor = args.fetch(:accessor) { raise ArgumentError, "accessor is required" }
      definition = args.fetch(:definition, {})

      @store[namespace] ||= {}.with_indifferent_access
      @store[namespace][accessor] = definition
    end

    def catalog
      sort_by { |key, _| key.to_s }.to_h.transform_values do |fields|
        fields.transform_values(&:values)
      end
    end
  end
end
