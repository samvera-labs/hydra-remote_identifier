require 'active_support/core_ext/class/attribute'

module Hydra::RemoteIdentifier

  # The Registration is responsible for connecting a RemoteService, a Target
  # to a particular Map
  class Registration
    def initialize(service_class, target_class, minting_coordinator = MintingCoordinator, &map)
      if map.nil?
        raise RuntimeError, "You attempted to register the remote service #{service_class} for #{target_class} without a map"
      end
      target_class.class_attribute :registered_remote_identifier_minters unless target_class.respond_to?(:registered_remote_identifier_minters)
      target_class.registered_remote_identifier_minters ||= []
      target_class.registered_remote_identifier_minters += [minting_coordinator.new(service_class, &map)]
    end
  end

end
