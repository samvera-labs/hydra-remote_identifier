require File.expand_path('../../../../../lib/hydra/remote_identifier/registration', __FILE__)
module Hydra::RemoteIdentifier

  describe Registration do
    let(:minting_coordinator) { double(new: :minting_coordinator) }
    let(:target_class) { Class.new }
    let(:remote_service) { double(accessor_name: :mint_my_remote_service) }
    let(:map) { lambda {|m| m.title :title } }
    subject { Registration.new(remote_service, minting_coordinator) }

    it 'requires a map' do
      expect { subject.register(target_class) }.to raise_error(RuntimeError)
    end

    it 'adds a .registered_remote_identifier_minters method' do
      expect {
        subject.register(target_class, &map)
      }.to change{ target_class.respond_to?(:registered_remote_identifier_minters) }.from(false).to(true)
    end

    context 'adds a #mint_remote_service attribute' do
      before(:each) do
        subject.register(target_class, &map)
      end
      let(:target) { target_class.new }

      it { expect(target).to respond_to(:mint_my_remote_service) }
      it { expect(target).to respond_to(:mint_my_remote_service=) }
      it { expect(target.mint_my_remote_service?).to eq(false) }
    end

    it 'registers the minting coordinator on the target class' do
      subject.register(target_class, &map)
      expect(target_class.registered_remote_identifier_minters).to eq [:minting_coordinator]
    end
  end
end
