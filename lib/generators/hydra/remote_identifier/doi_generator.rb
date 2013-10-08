require 'rails/generators'

class Hydra::RemoteIdentifier::DoiGenerator < Rails::Generators::Base
  DEFAULT_CREDENTIALS_PATH = 'config/doi.yml'

  desc 'Register the target class names as acceptable for DOI'
  class_option :credentials_path, type: :string, default: DEFAULT_CREDENTIALS_PATH, desc: 'Where can we find your DOI credentials'
  class_option :target, type: :string, default: ":permanent_uri", desc: "What is the object's permanent_uri"
  class_option :creator, type: :string, default: ":creator", desc: "Name of the object's creator"
  class_option :title, type: :string, default: ":title", desc: "Title of the created object"
  class_option :publisher, type: :string, default: ":publisher", desc: "Publisher of the created object"
  class_option :publication_year, type: :string, default: ":publication_year", desc: "Year the created object was published"
  class_option :set_identifier, type: :string, default: ":set_doi_identifier", desc: "Method on object to call when DOI is set"
  argument :targets, :type => :array, :default => [], :banner => "class_name class_name"

  def insert_doi
    inject_into_file(
      "config/initializers/hydra-remote_identifier_config.rb",
      after: /Hydra::RemoteIdentifier.*/
    ) do

      data = []
      data << ""
      data << %(  doi_credentials = Psych.load_file("#{credentials_path}"))
      data << %(  config.remote_service(:doi, doi_credentials) do |doi|)
      data << %(    doi.register(#{normalized_targets}) do |map|)
      data << %(      map.target #{options.fetch('target')})
      data << %(      map.creator #{options.fetch('creator')})
      data << %(      map.title #{options.fetch('title')})
      data << %(      map.publisher #{options.fetch('publisher')})
      data << %(      map.publicationyear #{options.fetch('publication_year')})
      data << %(      map.set_identifier #{options.fetch('set_identifier')})
      data << %(    end)
      data << %(  end)
      data << ""
      data.join("\n")

    end
  end

  def optionally_create_credentials_path
    if credentials_path == DEFAULT_CREDENTIALS_PATH
      require 'hydra/remote_identifier/remote_services/doi'
      create_file(
        credentials_path,
        Hydra::RemoteIdentifier::RemoteServices::Doi::TEST_CONFIGURATION.to_yaml
      )
    end
  end

  private
  def credentials_path
    options.fetch('credentials_path')
  end

  def normalized_targets
    targets.collect(&:classify).join(", ")
  end
end
