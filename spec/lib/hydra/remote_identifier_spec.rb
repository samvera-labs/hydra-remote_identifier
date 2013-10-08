require 'spec_helper'
require File.expand_path('../../../../lib/hydra/remote_identifier', __FILE__)
module Hydra::RemoteIdentifier

  describe 'public API' do
    before(:each) do
      Hydra::RemoteIdentifier.configure do |config|
        config.remote_service(:doi, doi_options) do |doi|
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

    describe '.with_remote_service' do

      it 'should yield the service if one is registered' do
        expect {|block|
          Hydra::RemoteIdentifier.with_registered_remote_service(:doi, target, &block)
        }.to yield_with_args(RemoteServices::Doi)
      end

      it 'should not yield the service is not registered' do
        expect {|block|
          Hydra::RemoteIdentifier.with_registered_remote_service(:alternate, target, &block)
        }.to_not yield_control
      end

      it 'should not yield the service if the target is not registered' do
        target = double
        expect {|block|
          Hydra::RemoteIdentifier.with_registered_remote_service(:doi, target, &block)
        }.to_not yield_control
      end

    end

    describe '.mint' do

      it 'works!', VCR::SpecSupport.merge(record: :new_episodes, cassette_name: 'doi-integration') do
        expect {
          Hydra::RemoteIdentifier.mint(:doi, target)
        }.to change(target, :set_identifier).from(nil).to(expected_doi)
      end

      it 'returns false if the target is not configured for identifiers' do
        expect(Hydra::RemoteIdentifier.mint(:doi, double)).to eq(false)
      end

    end

    describe '.requested_remote_identifiers_for' do

      it 'should yield when the remote identifier was requested' do
        target.mint_doi = '1'
        expect { |block|
          Hydra::RemoteIdentifier.requested_remote_identifiers_for(target, &block)
        }.to yield_with_args(instance_of(RemoteServices::Doi))
      end

      it 'should not yield when the remote identifier was not requested' do
        target.mint_doi = '0'
        expect { |block|
          Hydra::RemoteIdentifier.requested_remote_identifiers_for(target, &block)
        }.to_not yield_control
      end

      it 'should not yield when the remote identifier if target is not configured' do
        target = double
        expect { |block|
          Hydra::RemoteIdentifier.requested_remote_identifiers_for(target, &block)
        }.to_not yield_control
      end

    end

  end

end
