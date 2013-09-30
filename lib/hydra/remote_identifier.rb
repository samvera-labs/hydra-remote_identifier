require "hydra/remote_identifier/version"
require 'hydra/remote_identifier/registration'
require 'hydra/remote_identifier/remote_service'
require 'hydra/remote_identifier/remote_services'

module Hydra::RemoteIdentifier

  class << self

    def register(remote_service_name, target_class, registration_builder = Registration, &block)
      registration_builder.new(remote_service(remote_service_name), target_class, &block)
    end

    def remote_service(string)
      namespace_for_lookup = RemoteServices
      remote_service_class_name = string.to_s.gsub(/(?:^|_)([a-z])/) { $1.upcase }
      if namespace_for_lookup.const_defined?(remote_service_class_name)
        namespace_for_lookup.const_get(remote_service_class_name).new
      else
        raise NotImplementedError.new(
          "Unable to find #{self} remote_service '#{string}'. Consider creating #{namespace_for_lookup}::#{remote_service_class_name}"
        )
      end
    end

  end

end
