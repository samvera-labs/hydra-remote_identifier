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

    def mint(target)
      Hydra::RemoteIdentifier.mint(name, target)
    end

    def mint_if_applicable(target)
      Hydra::RemoteIdentifier.mint_if_applicable(name, target)
    end

    def accessor_name
      "mint_#{name}".to_sym
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