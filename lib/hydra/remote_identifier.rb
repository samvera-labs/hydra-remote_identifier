require "hydra/remote_identifier/version"
require 'hydra/remote_identifier/configuration'
require 'hydra/remote_identifier/registration'
require 'hydra/remote_identifier/remote_service'
require 'hydra/remote_identifier/remote_services'

module Hydra::RemoteIdentifier

  class << self

    # Used for configuring available RemoteService and any additional
    # initialization requirements for those RemoteServices (i.e. credentials)
    #
    # @example
    #     Hydra::RemoteIdentifier.configure do |config|
    #       config.register_remote_service(
    #         :doi,
    #         {
    #           username: 'apitest',
    #           password: 'apitest',
    #           shoulder: "sldr1",
    #           naa: "10.1000"
    #         }
    #       )
    #     end
    #
    # @yieldparam config [Configuration]
    attr_accessor :configuration
    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end

    # For the given :remote_service_name and :target_classes register the Map
    # to use for minting a remote identifier for instances of the
    # :target_classes
    #
    # @example
    #     Hydra::RemoteIdentifier.register(:doi, Book) do |map|
    #       map.what  {|book| book.title + ": " book.subtitle }
    #       map.who   :author_name
    #       map.set_identifier {|book, value| book.set_doi!(value)}
    #     end
    #
    # @param remote_service_name [#to_s] the name of a remote service we will
    #   use to mint the corresponding remote identifier
    # @param target_classes [Array<Class>] a collection of classes who's
    #   instances to which we will assign a remote identifier
    # @yieldparam map [Map] defines what attributes are required by the
    #   :remote_service as well as what the callback for what the
    #   :remote_resource should do (see Mapper::Wrapper)
    def register(remote_service_name, *target_classes, &map)
      Array(target_classes).flatten.compact.each do |target_class|
        remote_service = configuration.remote_service(remote_service_name)
        registration_builder.new(remote_service, target_class, &map)
      end
    end

    attr_writer :registration_builder

    private
    def registration_builder
      @registration_builder || Registration
    end

  end

end
