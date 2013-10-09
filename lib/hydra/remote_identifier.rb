require "hydra/remote_identifier/version"
require 'hydra/remote_identifier/configuration'
require 'hydra/remote_identifier/registration'
require 'hydra/remote_identifier/remote_service'
require 'hydra/remote_identifier/railtie' if defined?(Rails)

module Hydra::RemoteIdentifier

  class << self

    # Used for configuring available RemoteService and any additional
    # initialization requirements for those RemoteServices (i.e. credentials)
    #
    # @example
    #     Hydra::RemoteIdentifier.configure do |config|
    #       config.remote_service(:doi, doi_credentials) do |doi|
    #         doi.register(target_class) do |map|
    #           map.target :url
    #           map.creator :creator
    #           map.title :title
    #           map.publisher :publisher
    #           map.publicationyear :publicationyear
    #           map.set_identifier(:set_identifier=)
    #         end
    #       end
    #     end
    #
    # @yieldparam config [Configuration]
    # @see Hydra::RemoteIdentifier::Railtie
    def configure(&block)
      @configuration_block = block

      # The Rails load sequence means that some of the configured Targets may
      # not be loaded; As such I am not calling configure! instead relying on
      # Hydra::RemoteIdentifier::Railtie to handle the configure! call
      configure! unless defined?(Rails)
    end
    attr_accessor :configuration

    def configure!
      if @configuration_block.respond_to?(:call)
        self.configuration ||= Configuration.new
        @configuration_block.call(configuration)
      end
    end
    private :configure!

    # Yields the specified RemoteService if it _could_ be requested for the
    # Target.
    #
    # @example
    #     <% Hydra::RemoteIdentifier.with_registered_remote_service(:doi, book) do |remote_service| %>
    #       <%= f.input remote_service.accessor_name %>
    #     <% end %>
    #
    # @param remote_service_name [#to_s]
    # @param target [#registered_remote_identifier_minters]
    def with_registered_remote_service(remote_service_name, target)
      return false unless target.respond_to?(:registered_remote_identifier_minters)
      # @TODO - the registered remote identifier is more than a bit off;
      # but it continues to work
      target.registered_remote_identifier_minters.each {|coordinator|
        if coordinator.remote_service.name.to_s == remote_service_name.to_s
          yield(coordinator.remote_service)
        end
      }
    end

    # @example
    #    <%= link_to(object.doi, Hydra::RemoteIdentifier.remote_uri_for(:doi, object.doi)) %>
    #
    # @param remote_service_name [#to_s]
    # @param identifier[#to_s] - An identifier that was created by the
    #   RemoteService derived from the given remote_service_name
    # @returns [URI] - The URI for that identifier
    def remote_uri_for(remote_service_name, identifier)
      remote_service = configuration.find_remote_service(remote_service_name)
      remote_service.remote_uri_for(identifier)
    end

    # Yields each RemoteService#name that _is_ requested for the Target.
    #
    # @example
    #     Hydra::RemoteIdentifier.requested_remote_identifiers_for(book) do |remote_service_name|
    #       Hydra::RemoteIdentifier.mint(remote_service_name, book)
    #     end
    #
    # @param target [#registered_remote_identifier_minters]
    # @yield_param remote_service_name [#to_s]
    def requested_remote_identifiers_for(target)
      return false unless target.respond_to?(:registered_remote_identifier_minters)
      target.registered_remote_identifier_minters.each do |coordinator|
        remote_service = coordinator.remote_service
        if target.public_send(remote_service.accessor_name).to_i != 0
          yield(remote_service)
        end
      end
    end

    # Using the RemoteService mint the corresponding remote identifier for
    # the target. You must first configure the RemoteService and target's class
    # to define the attribute map. See Hydra::RemoteIdentifier.configure
    #
    # @example
    #     Hydra::RemoteIdentifier.mint(:doi, book)
    #
    # @param remote_service_name [#to_s]
    # @param target [#registered_remote_identifier_minters]
    def mint(remote_service_name, target)
      return false unless target.respond_to?(:registered_remote_identifier_minters)
      remote_service = configuration.find_remote_service(remote_service_name)
      coordinator = target.registered_remote_identifier_minters.detect do |c|
        c.remote_service.name == remote_service.name
      end
      coordinator.call(target) if coordinator
    end

  end

end
