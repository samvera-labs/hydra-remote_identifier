module Hydra::RemoteIdentifier

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
