require File.expand_path('../../../../../lib/hydra/remote_identifier/registration', __FILE__)
module Hydra::RemoteIdentifier

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
