require 'spec_helper'
require 'hydra/remote_identifier/remote_services/doi'

module Hydra::RemoteIdentifier
  module RemoteServices

    describe Doi do
      let(:configuration) { RemoteServices::Doi::TEST_CONFIGURATION }
      let(:payload) {
        {
          target: 'http://google.com',
          creator: 'Jeremy Friesen',
          title: 'My Article',
          publisher: 'Me Myself and I',
          publicationyear: "2013"
        }
      }
      let(:expected_doi) {
        # From the doi-create cassette
        'doi:10.5072/FK23J3QV8'
      }
      subject { RemoteServices::Doi.new(configuration) }

      context '.call' do
        it 'should post to remote service', VCR::SpecSupport(cassette_name: 'doi-create') do
          expect(subject.call(payload)).to eq(expected_doi)
        end
      end
    end
  end
end
