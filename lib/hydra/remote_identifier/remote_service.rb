module Hydra::RemoteIdentifier

  # The RemoteService is responsible for delivering a payload to a remote
  # identification minting service and returning an identifier.
  #
  # It is responsible for assisting the construction and validation of a remote
  # payload.
  class RemoteService

    def self.configure(*args, &block)
      raise NotImplementedError,
        "You must implement #{self.class}.configure"
    end

    def valid_attribute?(attribute_name)
      raise NotImplementedError,
        "You must implement #{self.class}#valid_attribute?"
    end

    def call(payload)
      raise NotImplementedError,
        "You must implement #{self.class}#call"
    end

  end

end