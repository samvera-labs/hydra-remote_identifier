require File.expand_path('../../../../../lib/hydra/remote_identifier/remote_service', __FILE__)

module Hydra::RemoteIdentifier

  describe RemoteService do

    let(:payload) { 'abc' }
    subject { RemoteService.new }

    its(:name) { should eq :remote_service }
    its(:accessor_name) { should eq :mint_remote_service }

    context '#call' do
      it { expect { subject.call(payload) }.to raise_error NotImplementedError }
    end

    context '#valid_attribute?' do
      it { expect { subject.valid_attribute?(:attribute_name) }.to raise_error NotImplementedError }
    end

    context '#mint' do
      it {
        Hydra::RemoteIdentifier.should_receive(:mint).with(:remote_service, :target)
        subject.mint(:target)
      }
    end

    context '#mint_if_applicable' do
      it {
        Hydra::RemoteIdentifier.should_receive(:mint_if_applicable).with(:remote_service, :target)
        subject.mint_if_applicable(:target)
      }
    end

  end

end
