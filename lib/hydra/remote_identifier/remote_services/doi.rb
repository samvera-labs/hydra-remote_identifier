require 'uri'
require 'rest_client'
require 'hydra/remote_identifier/remote_service'
require 'active_support/core_ext/hash/indifferent_access'

module Hydra::RemoteIdentifier
  module RemoteServices
    class Doi < Hydra::RemoteIdentifier::RemoteService
      TEST_CONFIGURATION =
      {
        username: 'apitest',
        password: 'apitest',
        shoulder: 'doi:10.5072/FK2',
        url: "https://n2t.net/ezid/"
      }

      attr_reader :uri
      def initialize(configuration = {})
        username = configuration.fetch(:username)
        password = configuration.fetch(:password)
        shoulder = configuration.fetch(:shoulder)
        url = configuration.fetch(:url)

        # This is specific for the creation of DOIs
        @uri = URI.parse(File.join(url, 'shoulder', shoulder))
        @uri.user = username
        @uri.password = password
      end

      REQUIRED_ATTRIBUTES = ['target', 'creator', 'title', 'publisher', 'publicationyear' ].freeze
      def valid_attribute?(attribute_name)
        REQUIRED_ATTRIBUTES.include?(attribute_name.to_s)
      end

      def call(payload)
        request(data_for_create(payload.with_indifferent_access))
      end

      private

      def request(data)
        response = RestClient.post(uri.to_s, data, content_type: 'text/plain')
        matched_data = /\Asuccess:(.*)(?<doi>doi:[^\|]*)(.*)\Z/.match(response.body)
        matched_data[:doi].strip
      end

      def data_for_create(payload)
        data = []
        data << "_target: #{payload.fetch(:target)}"
        data << "datacite.creator: #{payload.fetch(:creator)}"
        data << "datacite.title: #{payload.fetch(:title)}"
        data << "datacite.publisher: #{payload.fetch(:publisher)}"
        data << "datacite.publicationyear: #{payload.fetch(:publicationyear)}"
        data.join("\n")
      end
    end
  end
end
