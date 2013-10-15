require 'spec_helper'
require File.expand_path('../../../../lib/hydra/remote_identifier', __FILE__)
module Hydra::RemoteIdentifier

  describe 'public API' do
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
      'doi:10.5072/FK2FT8XZZ' # From the doi-create cassette
    }
    let(:doi_options) { RemoteServices::Doi::TEST_CONFIGURATION }

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

    context '.remote_service' do
      it 'should return an instance of the request service' do
        expect(Hydra::RemoteIdentifier.remote_service(:doi)).
          to be_kind_of(RemoteServices::Doi)
      end

      it 'should raise exception if it is not a valid remote service' do
        expect{
          Hydra::RemoteIdentifier.remote_service(:alternate)
        }.to raise_error(KeyError)
      end
    end


    context '.with_registered_remote_service' do
      it 'should yield the service if one is registered' do
        Hydra::RemoteIdentifier.with_registered_remote_service(:doi, target) do |arg1|
          @arg1 = arg1
        end
        expect(@arg1).to be_instance_of(RemoteServices::Doi)
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

    context '.registered?' do
      it 'should return true when registered' do
        expect(Hydra::RemoteIdentifier.registered?(:doi, target)).to eq(true)
      end

      it 'should yield true when registered' do
        expect { |b| Hydra::RemoteIdentifier.registered?(:doi, target, &b) }.to yield_control
      end

      it 'should yield a remote_service with one arg on the block' do
        Hydra::RemoteIdentifier.registered?(:doi, target) do |arg1|
          @arg1 = arg1
        end
        expect(@arg1).to be_instance_of(RemoteServices::Doi)
      end

      it 'should yield a remote_service and minting coordinator with two args' do
        Hydra::RemoteIdentifier.registered?(:doi, target) do |arg1, arg2|
          @arg1 = arg1
          @arg2 = arg2
        end
        expect(@arg1).to be_instance_of(RemoteServices::Doi)
        expect(@arg2).to be_instance_of(MintingCoordinator)
      end

      it 'should return false when not registered' do
        expect(Hydra::RemoteIdentifier.registered?(:doi, double)).to eq(false)
      end

      it 'should return false when service does not exist' do
        expect(Hydra::RemoteIdentifier.registered?(:alternate, double)).to eq(false)
      end

    end

    context '.remote_uri_for' do
      it {
        expect(Hydra::RemoteIdentifier.remote_uri_for(:doi, expected_doi)).
        to eq(URI.parse(File.join(doi_options.fetch(:url), expected_doi)))
      }
    end

    context '.requested_remote_identifiers_for' do
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

    context '.mint' do
      it 'works!', VCR::SpecSupport(record: :new_episodes, cassette_name: 'doi-integration') do
        expect {
          Hydra::RemoteIdentifier.mint(:doi, target)
        }.to change(target, :set_identifier).from(nil).to(expected_doi)
      end

      it 'returns true minting occurred', VCR::SpecSupport(record: :new_episodes, cassette_name: 'doi-integration') do
        expect(Hydra::RemoteIdentifier.mint(:doi, target)).to eq(true)
      end

      it 'returns false if the target is not configured for identifiers' do
        expect(Hydra::RemoteIdentifier.mint(:doi, double)).to eq(false)
      end
    end

  end

end