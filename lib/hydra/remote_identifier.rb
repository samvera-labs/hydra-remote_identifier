require "hydra/remote_identifier/version"
require 'hydra/remote_identifier/registration'

module Hydra::RemoteIdentifier

  def register(remote_service, target_class, &block)
    Registration.new(remote_service, target_class, &block)
  end
  module_function :register

end
