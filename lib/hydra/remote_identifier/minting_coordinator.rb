module Hydra::RemoteIdentifier

  class MintingCoordinator
    attr_reader :service_class, :target_class, :mapper
    def initialize(service_class, target_class, mapper_builder = Mapper, &map_config)
      @service_class = service_class
      @target_class = target_class
      @mapper = mapper_builder.new(service_class, &map_config)
    end

    # Responsible for passing attributes from the target, as per the map, to
    # the service and assigning the result of the service to the target, as per
    # the map.
    def call(target, minter = Minter)
      minter.call(service_class.new, wrap(target))
    end

    private
    def wrap(target)
      mapper.call(target)
    end
  end

  describe MintingCoordinator do
    let(:service_class) { Class.new { def self.valid_attribute?(*); true; end } }
    let(:target_class) { Class.new }
    let(:mapper_builder) { double(new: double(call: :wrapped_target)) }
    let(:target) { target_class.new }
    let(:map) { lambda {|*|} }
    subject { MintingCoordinator.new(service_class, target_class, mapper_builder, &map) }
    it 'forward delegates call to the minter' do
      minter = double
      minter.should_receive(:call).with(kind_of(service_class), :wrapped_target)
      subject.call(target, minter)
    end
  end
end