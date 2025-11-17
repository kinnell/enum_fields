# frozen_string_literal: true

require 'active_support/dependencies/autoload'
require 'active_support/inflector'
require 'active_support/core_ext/hash/indifferent_access'

module EnumFields
  extend ActiveSupport::Autoload

  autoload :Version
end
