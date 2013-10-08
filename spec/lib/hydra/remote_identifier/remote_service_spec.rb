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

  end

end
