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
require_relative 'enum_fields/base'

module EnumFields
  extend ActiveSupport::Concern
  extend ActiveSupport::Autoload

  autoload :Definition
  autoload :EnumField

  include Base
end
