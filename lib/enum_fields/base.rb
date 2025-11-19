# frozen_string_literal: true

module EnumFields
  module Base
    extend ActiveSupport::Concern

    class_methods do
      def enum_field(accessor, definition, options = {})
        raise MissingDefinitionsError unless definition.present?

        EnumField.define(
          model_class: self,
          accessor: accessor,
          definition: definition,
          options: options
        )
      end

      def enum_field_for(accessor)
        enum_fields[accessor]
      end

      def enum_field?(accessor)
        enum_fields.key?(accessor)
      end

      def enum_fields
        @enum_fields ||= {}.with_indifferent_access
      end
    end

    included do
      def enum_fields_metadata
        self.class.enum_fields.keys.index_with do |accessor|
          public_send("#{accessor}_metadata")
        end.with_indifferent_access
      end
    end
  end
end
