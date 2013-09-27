require 'active_support/core_ext/class/attribute'

module Hydra::RemoteIdentifier

  class Registration
    def initialize(service_class, target_class, minting_coordinator = MintingCoordinator, &map)
      if map.nil?
        raise RuntimeError, "You attempted to register the remote service #{service_class} for #{target_class} without a map"
      end
      target_class.class_attribute :registered_remote_identifier_minters unless target_class.respond_to?(:registered_remote_identifier_minters)
      target_class.registered_remote_identifier_minters ||= []
      target_class.registered_remote_identifier_minters += [minting_coordinator.new(service_class, target_class, &map)]
    end
  end

  describe Registration do

    let(:minting_coordinator) { double(new: :minting_coordinator) }
    let(:remote_service) { RemoteService }
    let(:target_class) { Class.new }
    let(:map) { lambda {|m| m.title :title } }

    it 'requires a map' do
      expect { Registration.new(remote_service, target_class, minting_coordinator) }.to raise_error(RuntimeError)
    end

    it 'adds a .registered_remote_identifier_minters method' do
      expect {
        Registration.new(remote_service, target_class, minting_coordinator, &map)
      }.to change{ target_class.respond_to?(:registered_remote_identifier_minters) }.from(false).to(true)
    end

    it 'adds a .registered_remote_identifier_minters method' do
      Registration.new(remote_service, target_class, minting_coordinator, &map)
      expect(target_class.registered_remote_identifier_minters).to eq [:minting_coordinator]
    end

    it 'should yield a map' do
      Registration.new(remote_service, target_class, minting_coordinator, &map)
    end

  end

end
