require "hydra/remote_identifier/version"
require 'hydra/remote_identifier/registration'
require 'hydra/remote_identifier/remote_service'
require 'hydra/remote_identifier/remote_services'

module Hydra::RemoteIdentifier

  class << self

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
        remote_service = RemoteServiceLookup(remote_service_name).new
        Registration.new(remote_service, target_class, &map)
      end
    end

  end

  # Given a string retrieve a RemoteService class.
  # @param string [#to_s]
  # @return [RemoteService]
  def RemoteServiceLookup(string)
    namespace_for_lookup = RemoteServices
    remote_service_class_name = string.to_s.gsub(/(?:^|_)([a-z])/) { $1.upcase }
    if namespace_for_lookup.const_defined?(remote_service_class_name)
      namespace_for_lookup.const_get(remote_service_class_name)
    else
      raise NotImplementedError.new(
        "Unable to find #{self} remote_service '#{string}'. Consider creating #{namespace_for_lookup}::#{remote_service_class_name}"
      )
    end
  end
  module_function :RemoteServiceLookup

  class Configuration < BasicObject
    def method_missing(method_name, *args, &block)
      ::Hydra::RemoteIdentifier::RemoteServiceLookup(method_name).configure(*args, &block)
    end
  end

end
