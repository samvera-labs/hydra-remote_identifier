require File.expand_path('../../../../../lib/hydra/remote_identifier/remote_service', __FILE__)

module Hydra::RemoteIdentifier

  describe RemoteService do

    let(:payload) { 'abc' }
    subject { RemoteService.new }

    context '#call' do
      it { expect { subject.call(payload) }.to raise_error NotImplementedError }
    end

    context '#valid_attribute?' do
      it { expect { subject.valid_attribute?(:attribute_name) }.to raise_error NotImplementedError }
    end

  end

end
