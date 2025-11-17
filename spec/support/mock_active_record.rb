# frozen_string_literal: true

module MockActiveRecord
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

      def validations
        @validations ||= {}
      end
    end

    def initialize(attributes = {})
      @attributes = attributes.stringify_keys
    end

    attr_reader :attributes

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
      self.class.validations.each do |field, options|
        value = @attributes[field.to_s]

        next unless options[:inclusion]

        allowed_values = options[:inclusion][:in]
        allow_nil = options[:inclusion][:allow_nil]

        next if value.nil? && allow_nil
        return false unless allowed_values.include?(value)
      end
      true
    end

    def invalid?
      !valid?
    end

    # Generate getter and setter for any attribute
    def method_missing(method_name, *args)
      method_str = method_name.to_s

      if method_str.end_with?('=')
        attr_name = method_str.chomp('=')
        @attributes[attr_name] = args.first
      elsif @attributes.key?(method_str)
        @attributes[method_str]
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      method_str = method_name.to_s
      method_str.end_with?('=') || @attributes.key?(method_str) || super
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
