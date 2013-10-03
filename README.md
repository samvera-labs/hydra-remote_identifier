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
      config.remote_service(
        :doi,
        {
          username: 'apitest',
          password: 'apitest',
          shoulder: "sldr1",
          naa: "10.1000"
        }
      )
    end


In your `./config/initializers` add a file that registers remote identification
services for a list of models:

    Hydra::RemoteIdentifier.register(:doi, Book) do |map|
      map.what  {|book| book.title + ": " book.subtitle }
      map.who   :author_name
      map.set_identifier {|book, value| book.set_doi!(value)}
    end
