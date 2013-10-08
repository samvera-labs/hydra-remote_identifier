module Hydra::RemoteIdentifier
  class Railtie < Rails::Railtie
    generators do
      require 'generators/hydra/remote_identifier/install_generator'
    end
  end
end