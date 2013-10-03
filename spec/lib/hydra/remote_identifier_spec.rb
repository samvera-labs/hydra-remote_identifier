require File.expand_path('../../../../lib/hydra/remote_identifier', __FILE__)
module Hydra::RemoteIdentifier

  describe '.configure' do

    let(:target_class) {
      Class.new {
        def url; 'http://google.com'; end
        def creator; 'my creator'; end
        def title; 'my title'; end
        def publisher; 'my publisher'; end
        def publicationyear; '2013'; end
        attr_accessor :set_identifier
      }
    }

    let(:target) { target_class.new }

    let(:expected_doi) {
      # From the doi-create cassette
      'doi:10.5072/FK2FT8XZZ'
    }

    let(:doi_options) {
      {
        username: 'apitest',
        password: 'apitest',
        shoulder: 'doi:10.5072/FK2',
        url: "https://n2t.net/ezid/"
      }
    }

    describe '.register API' do

      before(:each) do
        Hydra::RemoteIdentifier.configure do |config|
          config.configure_remote_service(:doi, doi_options) do |doi|
            doi.register(target_class) do |map|
              map.target :url
              map.creator :creator
              map.title :title
              map.publisher :publisher
              map.publicationyear :publicationyear
              map.set_identifier(:set_identifier=)
            end
          end
        end
      end

      it 'works!', VCR::SpecSupport.merge(record: :new_episodes, cassette_name: 'doi-integration') do
        expect {
          target_class.registered_remote_identifier_minters.each do |minter|
            minter.call(target)
          end
        }.to change(target, :set_identifier).from(nil).to(expected_doi)
      end

    end

  end

end
