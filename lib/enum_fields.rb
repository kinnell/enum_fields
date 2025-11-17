# frozen_string_literal: true

require 'delegate'
require 'active_support/concern'
require 'active_support/dependencies/autoload'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/array/extract_options'
require 'active_support/inflector'
require 'active_record'

require_relative 'enum_fields/errors'
require_relative 'enum_fields/version'

module EnumFields
  extend ActiveSupport::Concern
  extend ActiveSupport::Autoload

  autoload :Definition
  autoload :EnumField

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

    def enum_fields
      @enum_fields ||= {}.with_indifferent_access
    end
  end
end
