require File.expand_path('../../../../../lib/hydra/remote_identifier/remote_services', __FILE__)
module Hydra::RemoteIdentifier
  module RemoteServices
    class TestService
    end
  end

  describe '.remote_service' do
    context 'with valid remote service' do
      subject { Hydra::RemoteIdentifier.remote_service(:test_service) }
      it 'should return an instance of that service' do
        expect(subject).to be_instance_of RemoteServices::TestService
      end
    end
    context 'with invalid remote service' do
      subject { Hydra::RemoteIdentifier.remote_service(:missing_service) }
      it 'should raise a NotImplementedError' do
        expect { subject }.to raise_error NotImplementedError
      end
    end
  end
end
