# frozen_string_literal: true

module EnumFields
  class Configuration
    DEFAULTS = {
      scopeable: true,
      validatable: true,
      nullable: true,
      inquirable: true,
    }.freeze

    attr_accessor :scopeable, :validatable, :nullable, :inquirable

    def initialize
      reset!
    end

    def reset!
      DEFAULTS.each { |key, value| public_send("#{key}=", value) }
    end
  end
end
