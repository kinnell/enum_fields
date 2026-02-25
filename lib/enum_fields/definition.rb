# frozen_string_literal: true

module EnumFields
  class Definition < SimpleDelegator
    STANDARD_PROPERTIES = %i[
      value
      label
    ].freeze

    attr_reader :properties

    def initialize(data)
      @data = build(data)
      raise InvalidDefinitionsError, "Definitions must be a Hash or Array" unless valid_hash?(@data)

      @properties = Set.new(STANDARD_PROPERTIES)
      @properties.merge(@data.flat_map { |_, metadata| metadata.keys })

      super(@data)
    end

    def data
      __getobj__
    end

    def valid?
      valid_hash?(__getobj__)
    end

    private

    def build(input)
      output = begin
        case input
        when HashWithIndifferentAccess
          input
        when Hash
          input.with_indifferent_access
        when Array
          build_from_array(input)
        else
          raise InvalidDefinitionsError, "Invalid definitions format: #{input.class}"
        end
      end

      output.transform_values do |metadata|
        metadata = metadata.with_indifferent_access

        if metadata.key?(:label)
          metadata
        else
          metadata.merge(label: metadata[:value].to_s)
        end
      end
    end

    def build_from_array(input)
      input.to_h do |element|
        metadata = normalize_item(element)

        [normalize_key(metadata[:value]), metadata]
      end.with_indifferent_access
    end

    def normalize_item(item)
      if item.is_a?(Hash)
        item.with_indifferent_access
      else
        {
          value: item,
          label: item.to_s,
        }
      end
    end

    def normalize_key(value)
      value.to_s.to_sym
    end

    def valid_hash?(data)
      return false unless data.is_a?(HashWithIndifferentAccess)
      return false unless data.values.all? { |metadata| metadata.key?(:value) }

      true
    end
  end
end
