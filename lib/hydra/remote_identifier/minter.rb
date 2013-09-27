module Hydra::RemoteIdentifier

  # The Minter is responsible for passing the target's payload to the
  # RemoteService then setting the target's identifier based on the response
  # from the remote_service
  class Minter

    def self.call(coordinator, target)
      new(coordinator, target).call
    end

    attr_reader :service, :target

    def initialize(service, target)
      @service, @target = service, target
    end

    def call
      update_target(service.call(payload))
    end

    private

    def payload
      target.extract_payload
    end

    def update_target(identifier)
      target.set_identifier(identifier)
    end

  end

end
