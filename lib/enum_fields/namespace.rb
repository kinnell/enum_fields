# frozen_string_literal: true

module EnumFields
  class Namespace
    def initialize(namespace)
      @namespace = namespace
    end

    def enum_field(accessor, definition = {})
      EnumFields.register({
        namespace: @namespace,
        accessor: accessor,
        definition: definition,
      })
    end
  end
end
