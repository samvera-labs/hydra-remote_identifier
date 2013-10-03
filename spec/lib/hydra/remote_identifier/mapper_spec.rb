require File.expand_path('../../../../../lib/hydra/remote_identifier/mapper', __FILE__)
module Hydra::RemoteIdentifier
  describe Mapper do

    let(:service_class) { double }

    describe 'with valid mapping block' do
      before(:each) do
        service_class.should_receive(:valid_attribute?).with(:title).and_return(true)
      end
      subject {
        Mapper.new(service_class) { |map|
          map.title :title
          map.set_identifier :foo=
        }
      }
      let(:my_title) { 'abc' }
      let(:target) { double(title: my_title)}
      let(:identifier) { '123' }

      it { expect(subject.call(target)).to be_kind_of Mapper::Wrapper }

      it { expect(subject.call(target).extract_payload).to eq({ title: my_title }) }
      it {
        target.should_receive(:foo=).with(identifier)
        subject.call(target).set_identifier(identifier)
      }
    end

    describe 'with invalid mapping block' do
      it 'chokes on invalid attribute' do
        service_class.should_receive(:valid_attribute?).with(:title).and_return(false)
        expect {
          Mapper.new(service_class) { |map|
            map.title :title
            map.set_identifier :foo=
          }
        }.to raise_error(InvalidServiceMapping)
      end

      it 'chokes when set_identifier is not specified' do
        service_class.should_receive(:valid_attribute?).with(:title).and_return(true)
        expect {
          Mapper.new(service_class) { |map|
            map.title :title
          }
        }.to raise_error(InvalidServiceMapping)
      end
    end

    describe Mapper::Wrapper do
      subject { Mapper::Wrapper.new(map, target) }

      context 'extract_payload' do
        let(:target) { double(foo: :foo_value) }
        describe 'with implicit getter' do
          let(:map) { double(_getters: { bar: :foo } ) }
          its(:extract_payload) { should == {bar: :foo_value} }
        end

        describe 'with lambda getter' do
          let(:map) { double(_getters: { bar: lambda {|o| o.foo } } ) }
          its(:extract_payload) { should == {bar: :foo_value} }
        end

        describe 'with implicit datastream getter' do
          let(:target) {
            double(datastreams: {'datastream' => double(foo: :foo_value)})
          }
          let(:map) {
            double(_getters: { foo: { at: 'datastream' } } )
          }
          its(:extract_payload) { should == {foo: :foo_value} }
        end

        describe 'with explicit datastream getter' do
          let(:target) {
            double(datastreams: {'datastream' => double(blorg: :foo_value)})
          }
          let(:map) {
            double(_getters: { foo: { at: 'datastream', in: :blorg } } )
          }
          its(:extract_payload) { should == {foo: :foo_value} }
        end

      end

      context '#extract_payload' do

        let(:target) { double(foo: :foo_value) }
        describe 'with implicit getter' do
          let(:map) { double(_getters: { bar: :foo } ) }
          its(:extract_payload) { should == {bar: :foo_value} }
        end

        describe 'with lambda getter' do
          let(:map) { double(_getters: { bar: lambda {|o| o.foo } } ) }
          its(:extract_payload) { should == {bar: :foo_value} }
        end

        describe 'with implicit datastream getter' do
          let(:target) {
            double(datastreams: {'datastream' => double(foo: :foo_value)})
          }
          let(:map) {
            double(_getters: { foo: { at: 'datastream' } } )
          }
          its(:extract_payload) { should == {foo: :foo_value} }
        end

        describe 'with explicit datastream getter' do
          let(:target) {
            double(datastreams: {'datastream' => double(blorg: :foo_value)})
          }
          let(:map) {
            double(_getters: { foo: { at: 'datastream', in: :blorg } } )
          }
          its(:extract_payload) { should == {foo: :foo_value} }
        end

      end

      context '#set_identifier' do
        let(:target) { double }
        describe 'with implicit setter' do
          let(:map) { double(_setter: :bar) }
          specify {
            target.should_receive(:bar).with(:expected_identifier)
            subject.set_identifier(:expected_identifier)
          }
        end

        describe 'with lambda setter' do
          let(:map) { double(_setter: lambda {|o, v| o.foo = v  } ) }
          specify {
            target.should_receive(:foo=).with(:expected_identifier)
            subject.set_identifier(:expected_identifier)
          }
        end

        describe 'with explicit datastream getter' do
          let(:target) { double(datastreams: datastreams ) }
          let(:datastreams) { {'properties' => double } }
          let(:map) {
            double(_setter: { at: 'properties', in: :identifier } )
          }
          specify {
            datastreams['properties'].should_receive(:identifier=).with(:expected_identifier)
            subject.set_identifier(:expected_identifier)
          }
        end

      end

    end
  end
end
