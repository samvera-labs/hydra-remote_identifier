require File.expand_path('../../../../lib/hydra/remote_identifier', __FILE__)
module Hydra::RemoteIdentifier

  describe 'with custom remote service' do
    around do |example|
      module RemoteServices
        class MyRemoteService < ::Hydra::RemoteIdentifier::RemoteService
          def valid_attribute?(*)
            true
          end
          def call(payload)
            :remote_service_response
          end
        end
      end
      example.run
      RemoteServices.send(:remove_const, :MyRemoteService)
    end

    describe '.configure' do
      let(:configuration_options) { { user: "apitest", pass: "apitest", scheme: "doi" } }
      it 'yields to allow configuration of remote service' do
        RemoteServices::MyRemoteService.should_receive(:configure).
          with(configuration_options)
        Hydra::RemoteIdentifier.configure do |config|
          config.my_remote_service(configuration_options)
        end
      end
    end

    describe '.register' do

      let(:target_class) {
        Class.new {
          attr_reader :identifier
          def title; 'a special title'; end
          def update_identifier(value); @identifier = value; end
        }
      }
      let(:target) { target_class.new }

      it 'should update the registered identifier based on the registered attributes' do
        Hydra::RemoteIdentifier.register(:my_remote_service, target_class) do |config|
          config.title :title
          config.set_identifier :update_identifier
        end

        expect {
          target_class.registered_remote_identifier_minters.each do |minter|
            minter.call(target)
          end
        }.to change(target, :identifier).from(nil).to(:remote_service_response)

      end
    end

    describe '.RemoteServiceLookup' do
      context 'with valid remote service' do
        subject { Hydra::RemoteIdentifier::RemoteServiceLookup(:my_remote_service) }
        it 'should return an instance of that service' do
          expect(subject).to eq RemoteServices::MyRemoteService
        end
      end
      context 'with invalid remote service' do
        subject { Hydra::RemoteIdentifier::RemoteServiceLookup(:undefined_service) }
        it 'should raise a NotImplementedError' do
          expect { subject }.to raise_error NotImplementedError
        end
      end
    end

  end

end
