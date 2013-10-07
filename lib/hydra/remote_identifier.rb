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

    # @example
    #     Hydra::RemoteIdentifier.with_registered_remote_service(:doi, book) do |remote_service|
    #       Hydra::RemoteIdentifier.mint(:doi, book)
    #     end
    def with_registered_remote_service(service_name, target)
      # @TODO - the registered remote identifier is more than a bit off;
      # but it continues to work
      target.registered_remote_identifier_minters.each {|minter|
        if minter.remote_service.name.to_s == service_name.to_s
          yield(minter.remote_service)
        end
      }
    end

    # Using the RemoteService mint the corresponding remote identifier for
    # the target. You must first configure the RemoteService and target's class
    # to define the attribute map. See Hydra::RemoteIdentifier.configure
    #
    #
    # @example
    #     Hydra::RemoteIdentifier.mint(:doi, book)
    #
    # @param remote_service_name [#to_s]
    # @param target [#registered_remote_identifier_minters]
    def mint(remote_service_name, target)
      # @TODO - there is a better way to do this but this is "complete/correct"
      remote_service = configuration.find_remote_service(remote_service_name)
      target.registered_remote_identifier_minters.each do |minter|
        minter.call(target) if minter.remote_service == remote_service
      end
    end

  end

end
