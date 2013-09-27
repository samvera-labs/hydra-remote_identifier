module Hydra::RemoteIdentifier

  # The RemoteService is responsible for delivering a payload to a remote
  # identification minting service and returning an identifier.
  #
  # It is responsible for assisting the construction and validation of a remote
  # payload.
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