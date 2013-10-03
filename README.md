# Hydra::RemoteIdentifier

Coordinate the registration and minting of remote identifiers for persisted
objects.

## Installation

Add this line to your application's Gemfile:

    gem 'hydra-remote_identifier'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hydra-remote_identifier

## Usage

Configure your remote identifiers with credentials and what have you:

    Hydra::RemoteIdentifier.configure do |config|
      config.configure_remote_service(:doi, doi_credentials) do |doi|
        doi.register(target_class) do |map|
          map.target :url
          map.creator :creator
          map.title :title
          map.publisher :publisher
          map.publicationyear :publicationyear
          map.set_identifier(:set_identifier=)
        end
      end
    end
