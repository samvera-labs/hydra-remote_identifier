# Hydra::RemoteIdentifier

[![Gem Version](https://badge.fury.io/rb/hydra-remote_identifier.png)](http://badge.fury.io/rb/hydra-remote_identifier)

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

    doi_credentials = Psych.load('/path/to/doi_credentials.yml')
    Hydra::RemoteIdentifier.configure do |config|
      config.remote_service(:doi, doi_credentials) do |doi|
        doi.register(Book, Page) do |map|
          map.target :url
          map.creator :creator
          map.title :title
          map.publisher :publisher
          map.publicationyear :publicationyear
          map.set_identifier(:set_identifier=)
        end
      end
    end
