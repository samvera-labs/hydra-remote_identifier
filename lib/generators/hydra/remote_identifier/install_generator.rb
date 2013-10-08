require 'rails/generators'

class Hydra::RemoteIdentifier::InstallGenerator < Rails::Generators::Base
  def create_config
    initializer('hydra-remote_identifier_config.rb') do
      data = []

      data << '# Register and configure remote identifiers for persisted objects'
      data << 'Hydra::RemoteIdentifier.configure do |config|'
      data << '  # doi_credentials = Psych.load("/path/to/doi_credentials.yml")'
      data << '  # config.remote_service(:doi, doi_credentials) do |doi|'
      data << '  #   doi.register(PersistedObject) do |map|'
      data << '  #     map.target :url'
      data << '  #     map.creator {|obj| obj.person_name }'
      data << '  #     map.title :title'
      data << '  #     map.publisher :publisher'
      data << '  #     map.publicationyear :publicationyear'
      data << '  #     map.set_identifier :set_doi_identifier='
      data << '  #   end'
      data << '  # end'
      data << 'end'
      data << ''

      data.join("\n")
    end
  end
end
