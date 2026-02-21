# frozen_string_literal: true

module EnumFields
  class Registry < SimpleDelegator
    def initialize
      @store = {}.with_indifferent_access
      super(@store)
    end

    def register(model_class:, accessor:, definition:)
      key = model_class.name&.underscore || model_class.object_id.to_s
      @store[key] ||= {}.with_indifferent_access
      @store[key][accessor] = definition
    end
  end
end
