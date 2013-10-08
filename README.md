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
          map.creator {|obj| obj.person_name }
          map.title :title
          map.publisher :publisher
          map.publicationyear :publicationyear
          map.set_identifier(:set_identifier=)
        end
      end
    end

If you are using Rails, you can run `rails generate hydra:remote_identifier:install` to
create a Rails initializer with the above stub file.

In your views allow users to request that a remote identifier be assigned:

    <%= form_for book do |f| %>
      <% Hydra::RemoteIdentifier.with_registered_remote_service(:doi, f.object) do |remote_service| %>
        <%= f.input remote_service.accessor_name %>
      <% end %>
    <% end %>

Where you enqueue an asynchronous worker iterate over the requested identifiers:

    Hydra::RemoteIdentifier.applicable_remote_service_names_for(book) do |remote_service|
      MintRemoteIdentifierWorker.enqueue(book.to_param, remote_service.name)
    end

Where your asynchronouse worker does its work request the minting:

    # Instantiate target from input
    Hydra::RemoteIdentifier.mint(remote_service_name, target)

## Extending Hydra::RemoteIdentifier with alternate remote identifiers

If you are interested in creating a new Hydra::RemoteIdentifier::RemoteService,
this can be done by creating a class in the Hydra::RemoteIdentifier::RemoteServices
namespace. See below:

    module Hydra::RemoteIdentifier::RemoteServices
      class MyRemoteService < Hydra::RemoteIdentifier::RemoteService
        # your code here
      end
    end

Then configure your RemoteService for your persisted targets. See below:

    Hydra::RemoteIdentifier.configure do |config|
      config.remote_service(:my_remote_service, credentials) do |mine|
        mine.register(Book, Page) do |map|
          # map fields of Book, Page to the required payload for MyRemoteService
        end
      end
    end