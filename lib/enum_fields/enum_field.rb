# frozen_string_literal: true

module EnumFields
  class EnumField
    def self.define(**args)
      new(**args).define!
    end

    def initialize(model_class:, accessor:, definition:, options: {})
      @model_class = model_class
      @accessor = accessor.to_sym
      @column_name = options.fetch(:column, @accessor).to_sym
      @definition = Definition.new(definition)
    end

    def define!
      store_definition!
      define_class_methods!
      define_instance_getter!
      define_instance_setter!
      define_metadata_methods!
      define_property_methods!
      define_inquiry_methods!
      define_scopes!
      define_validation!
    end

    private

    def store_definition!
      @model_class.enum_fields[@accessor] = @definition.data
    end

    def define_class_methods!
      collection_name = @accessor.to_s.pluralize
      definition_data = @definition.data

      @model_class.define_singleton_method(collection_name) do
        definition_data
      end

      @model_class.define_singleton_method("#{collection_name}_count") do
        definition_data.size
      end

      @model_class.define_singleton_method("#{@accessor}_values") do
        definition_data.values.pluck(:value)
      end

      @model_class.define_singleton_method("#{@accessor}_options") do
        definition_data.map do |key, metadata|
          [metadata[:label], key.to_s]
        end
      end
    end

    def define_instance_getter!
      return if @accessor == @column_name

      accessor = @accessor
      column_name = @column_name

      @model_class.define_method(accessor) do
        attributes[column_name.to_s]
      end
    end

    def define_instance_setter!
      return if @accessor == @column_name

      accessor = @accessor
      column_name = @column_name

      @model_class.define_method("#{accessor}=") do |value|
        public_send("#{column_name}=", value)
      end
    end

    def define_metadata_methods!
      accessor = @accessor
      column_name = @column_name

      @model_class.define_method("#{accessor}_metadata") do
        column_value = attributes[column_name.to_s]
        return nil if column_value.nil?

        definitions = self.class.enum_field_for(accessor)
        return nil if definitions.blank?

        definitions[column_value]
      end
    end

    def define_property_methods!
      accessor = @accessor
      column_name = @column_name

      @definition.properties.each do |property|
        @model_class.define_method("#{accessor}_#{property}") do
          column_value = attributes[column_name.to_s]
          return nil if column_value.nil?

          definitions = self.class.enum_field_for(accessor)
          return nil if definitions.blank?

          definitions.dig(column_value, property)
        end
      end
    end

    def define_inquiry_methods!
      accessor = @accessor
      column_name = @column_name

      @definition.each do |key, metadata|
        definition_value = metadata[:value]
        @model_class.define_method("#{key}_#{accessor}?") do
          public_send(column_name) == definition_value
        end
      end
    end

    def define_scopes!
      column_name = @column_name

      @definition.each do |key, metadata|
        definition_value = metadata[:value]
        @model_class.scope("#{key}_#{@accessor}", -> { where(column_name => definition_value) })
      end
    end

    def define_validation!
      return if @definition.blank?

      valid_values = @definition.values.pluck(:value)
      @model_class.validates(@column_name, inclusion: {
        in: valid_values,
        allow_nil: true,
      })
    end
  end
end
