require File.expand_path('../remote_services', __FILE__)
require File.expand_path('../registration', __FILE__)

module Hydra
  module RemoteIdentifier

    # Configuration is responsible for exposing the available RemoteServices
    # and configuring those RemoteServices.
    class Configuration

      def initialize(options = {})
        @remote_service_namespace_container = options.fetch(:remote_service_namespace_container, RemoteServices)
        @registration_builder = options.fetch(:registration_builder, Registration)
        @remote_services = {}
      end
      attr_reader :remote_service_namespace_container, :registration_builder
      private :remote_service_namespace_container, :registration_builder
      attr_reader :remote_services

      def find_remote_service(service_name)
        remote_services.fetch(service_name.to_sym)
      end

      # @param service_name [#to_s]
      # @param args - passed through to RemoteService initializer
      #
      # @yieldparam [Registration]
      def remote_service(service_name, *args)
        remote_service = find_or_store_remote_service(service_name, *args)
        registration = registration_builder.new(remote_service)
        yield(registration)
        remote_service
      end

      private
      def find_or_store_remote_service(service_name, *args)
        remote_services[service_name.to_sym] ||= remote_service_class_lookup(service_name).new(*args)
        remote_services.fetch(service_name.to_sym)
      end

      def remote_service_class_lookup(string)
        remote_service_class_name = string.to_s.gsub(/(?:^|_)([a-z])/) { $1.upcase }
        if remote_service_namespace_container.const_defined?(remote_service_class_name)
          remote_service_namespace_container.const_get(remote_service_class_name)
        else
          raise NotImplementedError.new(
            "Unable to find #{self} remote_service '#{string}'. Consider creating #{remote_service_namespace_container}::#{remote_service_class_name}"
          )
        end
      end
    end

  end
end
