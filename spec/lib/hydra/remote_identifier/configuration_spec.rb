require File.expand_path('../../../../../lib/hydra/remote_identifier/configuration', __FILE__)

module Hydra::RemoteIdentifier

  describe Configuration do
    around do |example|
      module RemoteServices
        class MyRemoteService
          attr_reader :options
          def initialize(*options)
            @options = options
          end
        end
      end
      example.run
      RemoteServices.send(:remove_const, :MyRemoteService)
    end

    subject { Configuration.new(registration_builder: registration_builder) }
    let(:registration_builder) {
      Class.new do
        attr_reader :remote_service
        def initialize(remote_service)
          @remote_service = remote_service
        end
      end
    }
    context 'with a missing service' do
      specify do
        expect {
          subject.remote_service(:obviously_missing_service)
        }.to raise_error(NotImplementedError)
      end
    end

    context 'with an existing service' do
      let(:block) { lambda {} }
      specify do
        expect {|reg|
          subject.remote_service(:my_remote_service, &reg)
        }.to yield_with_args(registration_builder)
      end
    end
  end

end
