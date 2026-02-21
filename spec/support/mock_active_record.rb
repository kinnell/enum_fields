# frozen_string_literal: true

module MockActiveRecord
  class MockReflection
    attr_reader :name, :options

    def initialize(name, options = {})
      @name = name
      @options = options
    end
  end

  class MockErrors
    def initialize
      @errors = {}
    end

    def add(field, message)
      @errors[field] ||= []
      @errors[field] << message
    end

    def empty?
      @errors.empty?
    end

    def [](field)
      @errors[field] || []
    end

    def clear
      @errors = {}
    end
  end

  class Base
    class << self
      def scope(name, body)
        define_singleton_method(name) do
          MockRelation.new(self, body)
        end
      end

      def validates(field, options = {})
        @validations ||= {}
        @validations[field] = options
      end

      def validate(&block)
        @custom_validations ||= []
        @custom_validations << block
      end

      def validations
        @validations ||= {}
      end

      def custom_validations
        @custom_validations ||= []
      end

      def belongs_to(name, options = {})
        @associations ||= []
        @associations << MockReflection.new(name, options)

        return unless options[:polymorphic]

        define_method(name) do
          @polymorphic_associations ||= {}
          @polymorphic_associations[name]
        end

        define_method("#{name}=") do |value|
          @polymorphic_associations ||= {}
          @polymorphic_associations[name] = value
          @attributes["#{name}_type"] = value&.class&.name
          @attributes["#{name}_id"] = value&.id
        end
      end

      def reflect_on_all_associations(type = nil)
        @associations ||= []
        return @associations if type.nil?
        return @associations if type == :belongs_to

        []
      end
    end

    def initialize(attributes = {})
      @attributes = attributes.stringify_keys
      @polymorphic_associations = {}
      @errors = MockErrors.new
    end

    attr_reader :attributes, :errors

    def [](key)
      @attributes[key.to_s]
    end

    def []=(key, value)
      @attributes[key.to_s] = value
    end

    def update(attributes)
      attributes.each do |key, value|
        public_send("#{key}=", value)
      end

      valid?
    end

    def valid?
      @errors.clear

      self.class.validations.each do |field, options|
        value = @attributes[field.to_s]

        next unless options[:inclusion]

        allowed_values = options[:inclusion][:in]
        allow_nil = options[:inclusion][:allow_nil]

        next if value.nil? && allow_nil

        unless allowed_values.include?(value)
          @errors.add(field, "is not included in the list")
          return false
        end
      end

      self.class.custom_validations.each do |validation_block|
        instance_eval(&validation_block)
      end

      @errors.empty?
    end

    def invalid?
      !valid?
    end

    def method_missing(method_name, *args)
      method_str = method_name.to_s

      if method_str.end_with?("=")
        attr_name = method_str.chomp("=")
        @attributes[attr_name] = args.first
      elsif @attributes.key?(method_str)
        @attributes[method_str]
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      method_str = method_name.to_s
      method_str.end_with?("=") || @attributes.key?(method_str) || super
    end
  end

  class MockRelation
    def initialize(klass, body)
      @klass = klass
      @body = body
    end

    def to_sql
      @to_sql ||= begin
        table_name = "with_model_test_models_#{rand(100_000)}_#{rand(100_000)}"

        "SELECT \"#{table_name}\".* FROM \"#{table_name}\" WHERE \"#{table_name}\".\"sample_column\" = 'value'"
      end
    end
  end
end
