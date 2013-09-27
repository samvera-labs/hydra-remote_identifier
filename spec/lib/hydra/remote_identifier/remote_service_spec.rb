require File.expand_path('../../../../../lib/hydra/remote_identifier/remote_service', __FILE__)

module Hydra::RemoteIdentifier

  describe RemoteService do
    let(:payload) { 'abc' }
    subject { RemoteService.new }

    it { expect { subject.call(payload) }.to raise_error NotImplementedError }

  end

end