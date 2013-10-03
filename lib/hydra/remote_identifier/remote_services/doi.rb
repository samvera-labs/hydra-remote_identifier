require 'uri'
require 'rest_client'
require 'hydra/remote_identifier/remote_service'
require 'active_support/core_ext/hash/indifferent_access'

module Hydra::RemoteIdentifier
  module RemoteServices
    class Doi < Hydra::RemoteIdentifier::RemoteService

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
        [
          "_target: #{payload.fetch(:target)}",
          "datacite.creator: #{payload.fetch(:creator)}",
          "datacite.title: #{payload.fetch(:title)}",
          "datacite.publisher: #{payload.fetch(:publisher)}",
          "datacite.publicationyear: #{payload.fetch(:publicationyear)}"
        ].join("\n")
      end
    end
  end
end
