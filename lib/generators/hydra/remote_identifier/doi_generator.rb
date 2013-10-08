require 'rails/generators'

class Hydra::RemoteIdentifier::DoiGenerator < Rails::Generators::Base
  desc 'Register the target class names as acceptable for DOI'
  class_options credentials_path: :string
  argument :targets, :type => :array, :default => [], :banner => "class_name class_name"

  def create
    inject_into_file(
      "config/initializers/hydra-remote_identifier_config.rb",
      after: /Hydra::RemoteIdentifier.*/
    ) do

      data = []
      data << ""
      data << %(  doi_credentials = Psych.load("#{credentials_path}"))
      data << %(  config.remote_service(:doi, doi_credentials) do |doi|)
      data << %(    doi.register(#{normalized_targets}) do |map|)
      data << %(      map.target {|obj| obj.permanent_uri })
      data << %(      map.creator :creator)
      data << %(      map.title :title)
      data << %(      map.publisher :publisher)
      data << %(      map.publicationyear :publicationyear)
      data << %(      map.set_identifier {|obj,value| obj.set_doi(value) })
      data << %(    end)
      data << %(  end)
      data << ""
      data.join("\n")

    end
  end

  private
  def credentials_path
    options.fetch('credentials_path', "./path/to/doi_credentials.yml")
  end

  def normalized_targets
    targets.collect(&:classify).join(", ")
  end
end
