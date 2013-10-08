require "hydra/remote_identifier/version"
require 'hydra/remote_identifier/configuration'
require 'hydra/remote_identifier/registration'
require 'hydra/remote_identifier/remote_service'

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
    attr_accessor :configuration
    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end

    # Yields the specified RemoteService if it _could_ be requested for the
    # Target.
    #
    # @example
    #     <% Hydra::RemoteIdentifier.with_registered_remote_service(:doi, book) do |remote_service| %>
    #       <%= f.input remote_service.accessor_name %>
    #     <% end %>
    #
    # @param remote_service_name [#to_s]
    # @param target [#registered_remote_identifier_minters] (see Hydra::RemoteIdentifier.configure)
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


    # Yields each RemoteService#name that _is_ requested for the Target.
    #
    # @example
    #     Hydra::RemoteIdentifier.requested_remote_identifiers_for(book) do |remote_service_name|
    #       Hydra::RemoteIdentifier.mint(remote_service_name, book)
    #     end
    #
    # @param target [#registered_remote_identifier_minters] (see Hydra::RemoteIdentifier.configure)
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
    # @param target [#registered_remote_identifier_minters] (see Hydra::RemoteIdentifier.configure)
    def mint(remote_service_name, target)
      return false unless target.respond_to?(:registered_remote_identifier_minters)

      # @TODO - there is a better way to do this but this is "complete/correct"
      remote_service = configuration.find_remote_service(remote_service_name)
      target.registered_remote_identifier_minters.each do |coordinator|
        coordinator.call(target) if coordinator.remote_service == remote_service
      end
    end

  end

end
