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
      end
    end
  end
end
