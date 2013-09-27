module Hydra::RemoteIdentifier
  class InvalidServiceMapping < RuntimeError
    def initialize(errors)
      super(errors.join(". ") << '.')
    end
  end
  class Mapper

    class Wrapper
      attr_reader :map, :target
      def initialize(map, target)
        @map, @target = map, target
      end

      def extract_payload
        map._getters.each_with_object({}) do |(key, getter), mem|
          mem[key] = extract_attribute_for(target, getter, key)
          mem
        end
      end

      def set_identifier(identifier)
        update_target(map._setter, target, identifier)
      end

      private

      def update_target(setter, target, value)
        if setter.respond_to?(:call)
          setter.call(target, value)
        elsif setter.is_a?(Symbol) || setter.is_a?(String)
          target.send(setter, value)
        elsif setter.is_a?(Hash)
          datastream = setter.fetch(:at)
          field = setter.fetch(:in, scheme)
          target.datastreams["#{datastream}"].send("#{field}=", value)
        end
      end

      def extract_attribute_for(target, getter, field_name)
        if getter.respond_to?(:call)
          getter.call(target)
        elsif getter.is_a?(::Symbol) || getter.is_a?(::String)
          target.send(getter)
        elsif getter.is_a?(::Hash)
          datastream = getter.fetch(:at)
          field = getter.fetch(:in, field_name)
          target.datastreams["#{datastream}"].send("#{field}")
        end
      end
    end

    class Map < BasicObject
      attr_reader :service_class, :_getters, :_setter
      def initialize(service_class, &config)
        @service_class = service_class
        @_setter = nil
        @_getters = {}
        @errors = []
        config.call(self)
        if @_setter.nil?
          @errors << "Missing :set_identifier"
        end
        ::Kernel.raise ::Hydra::RemoteIdentifier::InvalidServiceMapping.new(@errors) if @errors.any?
      end

      def inspect
        "#<Hydra::RemoteIdentifier::Mapper::Map for #{service_class} (#{__FILE__})>"
      end

      def method_missing(method_name, *args, &block)
        if method_name == :set_identifier
          @_setter = args.first || block
        elsif service_class.valid_attribute?(method_name)
          @_getters[method_name] = args.first || block
        else
          @errors << "Invalid mapping #{method_name}"
        end
      end
    end

    attr_reader :map
    def initialize(service_class, map_builder = Map, &mapping_block)
      @map = map_builder.new(service_class, &mapping_block)
    end

    def call(target, wrapper_builder = Wrapper)
      wrapper_builder.new(map, target)
    end

  end

end
