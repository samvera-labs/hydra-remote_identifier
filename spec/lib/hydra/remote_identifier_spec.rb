require File.expand_path('../../../../lib/hydra/remote_identifier', __FILE__)
module Hydra::RemoteIdentifier

  describe '.register' do
    let(:remote_service) {
      Class.new(RemoteService) {
        def self.valid_attribute?(*)
          true
        end
        def call(payload)
          :remote_service_response
        end
      }
    }
    let(:target_class) {
      Class.new {
        attr_reader :identifier
        def title; 'a special title'; end
        def update_identifier(value); @identifier = value; end
      }
    }
    let(:target) { target_class.new }

    it 'should update the registered identifier based on the registered attributes' do
      Hydra::RemoteIdentifier.register(remote_service, target_class) do |config|
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

end
