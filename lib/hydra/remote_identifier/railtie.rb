module Hydra::RemoteIdentifier
  class Railtie < Rails::Railtie
    generators do
      require 'generators/hydra/remote_identifier/install_generator'
      require 'generators/hydra/remote_identifier/doi_generator'
    end

    config.to_prepare do
      Hydra::RemoteIdentifier.send(:configure!)
    end
  end
end