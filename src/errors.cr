module Kuzu
  class Error < ::Exception
    macro define(name)
      class {{name}} < {{@type}}
      end
    end
  end

  Error.define CannotAllocateConnection
  Error.define QueryError
  Error.define MissingProperty
end
