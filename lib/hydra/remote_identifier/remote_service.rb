module Hydra::RemoteIdentifier

  class RemoteService

    def self.valid_attribute?(attribute_name)
      true
    end

    def call(payload)
      raise NotImplementedError,
        "You must implement #{self.class}#call"
    end

  end

end