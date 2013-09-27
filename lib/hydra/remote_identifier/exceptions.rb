module Hydra::RemoteIdentifier
  class InvalidServiceMapping < RuntimeError
    def initialize(errors)
      super(errors.join(". ") << '.')
    end
  end
end