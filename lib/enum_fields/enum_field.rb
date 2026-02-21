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
      @options = options
    end

    def define!
      register!
      store_definition!
      define_class_methods!
      define_class_value_accessors!
      define_instance_getter!
      define_instance_setter!
      define_metadata_methods!
      define_property_methods!
      define_inquiry_methods!
      define_scopes!
      define_validation!
    end

    private

    def register!
      EnumFields.register(
        model_class: @model_class,
        accessor: @accessor,
        definition: @definition.data
      )
    end

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

    def define_class_value_accessors!
      accessor = @accessor

      @definition.each do |key, metadata|
        definition_value = metadata[:value]

        @model_class.define_singleton_method("#{key}_#{accessor}_value") do
          definition_value
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

        definitions[column_value] || definitions.values.find { |d| d[:value] == column_value }
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

          metadata = definitions[column_value] || definitions.values.find { |d| d[:value] == column_value }
          metadata&.dig(property)
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
      return unless column_validatable?

      if column_polymorphic_association_name.present?
        define_polymorphic_validation!
      else
        define_standard_validation!
      end
    end

    def define_standard_validation!
      valid_values = @definition.values.pluck(:value)

      @model_class.validates(@column_name, inclusion: {
        in: valid_values,
        allow_nil: true,
      })
    end

    def define_polymorphic_validation!
      association_name = column_polymorphic_association_name
      column_name = @column_name
      accessor = @accessor

      @model_class.validate do
        association_obj = respond_to?(association_name) ? public_send(association_name) : nil
        valid_values = self.class.public_send("#{accessor}_values")

        if association_obj
          errors.add(association_name, "must be one of: #{valid_values.join(', ')}") unless valid_values.include?(association_obj.class.name)
        else
          column_value = attributes[column_name.to_s]
          next if column_value.nil?

          errors.add(column_name, "must be one of: #{valid_values.join(', ')}") unless valid_values.include?(column_value)
        end
      end
    end

    def column_validatable?
      @definition.present? && @options.fetch(:validate, true)
    end

    def column_polymorphic_association_name
      return nil unless @model_class.respond_to?(:reflect_on_all_associations)

      reflection = @model_class.reflect_on_all_associations(:belongs_to).find do |r|
        r.options[:polymorphic] && "#{r.name}_type" == @column_name.to_s
      end

      reflection&.name
    end
  end
end
