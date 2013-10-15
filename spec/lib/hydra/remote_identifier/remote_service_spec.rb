require File.expand_path('../../../../../lib/hydra/remote_identifier/remote_service', __FILE__)

module Hydra::RemoteIdentifier

  describe RemoteService do

    let(:payload) { 'abc' }
    let(:target) { double }
    subject { RemoteService.new }

    its(:name) { should eq :remote_service }
    its(:accessor_name) { should eq :mint_remote_service }
    its(:to_s) { should eq 'remote_service' }

    context '#call' do
      it { expect { subject.call(payload) }.to raise_error NotImplementedError }
    end

    context '#remote_uri_for' do
      it { expect { subject.remote_uri_for(target) }.to raise_error NotImplementedError }
    end

    context '#valid_attribute?' do
      it { expect { subject.valid_attribute?(:attribute_name) }.to raise_error NotImplementedError }
    end

    context '#mint' do
      it 'should forward delegate to Hydra::RemoteService' do
        Hydra::RemoteIdentifier.should_receive(:mint).with(subject, target)
        subject.mint(target)
      end
    end
    context '#registered?' do
      it 'should forward delegate to Hydra::RemoteService' do
        Hydra::RemoteIdentifier.should_receive(:registered?).with(subject, target).and_return(:returning_value)
        expect(subject.registered?(target)).to eq(:returning_value)
      end
    end
  end

end
