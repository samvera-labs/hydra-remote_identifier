require File.expand_path('../mapper', __FILE__)
require File.expand_path('../minter', __FILE__)

module Hydra
  module RemoteIdentifier

    # The Minting
    class MintingCoordinator
      attr_reader :remote_service, :mapper
      def initialize(remote_service, mapper_builder = Mapper, &map_config)
        @remote_service = remote_service
        @mapper = mapper_builder.new(remote_service, &map_config)
      end

      # Responsible for passing attributes from the target, as per the map, to
      # the service and assigning the result of the service to the target, as per
      # the map.
      def call(target, minter = Minter)
        minter.call(remote_service, wrap(target))
      end

      private
      def wrap(target)
        mapper.call(target)
      end
    end

  end
end
