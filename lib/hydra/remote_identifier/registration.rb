require 'active_support/core_ext/class/attribute'
require File.expand_path('../minting_coordinator', __FILE__)

module Hydra
  module RemoteIdentifier

    # The Registration is responsible for connecting a RemoteService and a Target
    # to a particular Map
    class Registration
      attr_reader :remote_service, :minting_coordinator
      def initialize(remote_service, minting_coordinator = MintingCoordinator, &map)
        @remote_service = remote_service
        @minting_coordinator = minting_coordinator
      end

      # @param target_classes [Array]
      # @yieldparam map [Map]
      def register(*target_classes, &map)
        if map.nil?
          raise RuntimeError, "You attempted to register the remote service #{remote_service} for #{target_classes} without a map"
        end
        Array(target_classes).flatten.compact.each {|target_class|
          register_target(target_class, &map)
        }
      end

      private

      def register_target(target_class, &map)
        target_class.module_exec(remote_service) do |service|
          unless target_class.respond_to?(:registered_remote_identifier_minters)
            class_attribute :registered_remote_identifier_minters
          end
          attr_accessor service.accessor_name
          define_method("#{service.accessor_name}?") do
            instance_variable_get("@#{service.accessor_name}").to_i != 0
          end
        end
        target_class.registered_remote_identifier_minters ||= []
        target_class.registered_remote_identifier_minters += [minting_coordinator.new(remote_service, &map)]
      end
    end

  end
end
