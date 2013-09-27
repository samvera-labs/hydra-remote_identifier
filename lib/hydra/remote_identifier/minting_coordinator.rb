module Hydra::RemoteIdentifier

  # The Minting
  class MintingCoordinator
    attr_reader :service_class, :mapper
    def initialize(service_class, mapper_builder = Mapper, &map_config)
      @service_class = service_class
      @mapper = mapper_builder.new(service_class, &map_config)
    end

    # Responsible for passing attributes from the target, as per the map, to
    # the service and assigning the result of the service to the target, as per
    # the map.
    def call(target, minter = Minter)
      minter.call(service_class.new, wrap(target))
    end

    private
    def wrap(target)
      mapper.call(target)
    end
  end

end
