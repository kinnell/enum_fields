# frozen_string_literal: true

require "delegate"
require "active_support/concern"
require "active_support/dependencies/autoload"
require "active_support/core_ext/hash/indifferent_access"
require "active_support/core_ext/array/extract_options"
require "active_support/inflector"
require "active_record"

require_relative "enum_fields/configuration"
require_relative "enum_fields/errors"
require_relative "enum_fields/version"
require_relative "enum_fields/base"

module EnumFields
  extend ActiveSupport::Concern
  extend ActiveSupport::Autoload

  autoload :Definition
  autoload :EnumField
  autoload :Namespace
  autoload :Registry

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.reset_configuration!
    @configuration = Configuration.new
  end

  def self.registry
    @registry ||= Registry.new
  end

  def self.register(...)
    registry.register(...)
  end

  def self.namespace(name, &)
    Namespace.new(name).instance_eval(&)
  end

  def self.catalog
    registry.catalog
  end

  def self.clear_registry!
    @registry = nil
  end

  include Base
end
