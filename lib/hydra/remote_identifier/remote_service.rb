require 'active_support/core_ext/string/inflections'
module Hydra::RemoteIdentifier

  # The RemoteService is responsible for delivering a payload to a remote
  # identification minting service and returning an identifier.
  #
  # It is responsible for assisting the construction and validation of a remote
  # payload.
  class RemoteService

    def name
      self.class.to_s.demodulize.underscore.to_sym
    end

    def to_s
      name.to_s
    end

    def registered?(target)
      Hydra::RemoteIdentifier.registered?(self, target)
    end

    def mint(target)
      Hydra::RemoteIdentifier.mint(self, target)
    end

    # @param identifier[#to_s] - An identifier that was created by this remote
    #   service
    # @returns [URI] - The URI for that identifier
    def remote_uri_for(identifier)
      raise NotImplementedError,
        "You must implement #{self.class}#remote_uri_for(identifier)"
    end

    # When mapping a Target to a RemoteService, this is the name of the
    # :attr_accessor that will be created on the Target; Helpful for form
    # construction.
    #
    # @returns [Symbol]
    def accessor_name
      "mint_#{name}".to_sym
    end

    # @param identifier[#to_s] - The name of an attribute that is
    #
    # @returns [boolean] - Is this a valid attribute to send as part of the
    #   payload for RemoteService#call
    def valid_attribute?(attribute_name)
      raise NotImplementedError,
        "You must implement #{self.class}#valid_attribute?"
    end

    # @param payload[Hash] - A map with key/value pairs of valid attribute names
    #   and corresponding values that will be used to create the remote
    #   identifier
    # @return - The remote identifier that was created
    #
    # @see RemoteService#valid_attribute?
    def call(payload)
      raise NotImplementedError,
        "You must implement #{self.class}#call"
    end

  end

end