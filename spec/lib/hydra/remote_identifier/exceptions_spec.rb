require 'spec_helper'
require File.expand_path('../../../../../lib/hydra/remote_identifier/exceptions', __FILE__)
module Hydra::RemoteIdentifier
  describe RemoteServiceError do
    let(:payload) { "This is my payload!" }
    let(:uri) { URI.parse('http://username:password@hello-world.com/path/to/resource?show=1') }
    let(:exception) { double(http_code: '400 Bad Request', http_body: 'This is the raw response') }
    subject { RemoteServiceError.new(exception, uri, payload) }

    let(:expected_message) {
      x = []
      x << 'response.code: "400 Bad Request"'
      x << 'response.body: "This is the raw response"'
      x << ''
      x << 'request.uri: "http://xxx:xxx@hello-world.com/path/to/resource?show=1"'
      x << 'request.payload: "This is my payload!"'
      x << ''
      x.join("\n")
    }

    its(:to_s) { should eq(expected_message) }
  end
end
