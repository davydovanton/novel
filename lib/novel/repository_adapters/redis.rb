module Novel
  module RepositoryAdapters
    class Redis
      attr_reader :connection_pool

      class UnitStub < Object
        def inspect
          "unit_stub"
        end
      end

      def initialize(connection_pool:)
        @connection_pool = connection_pool
      end

      def deserialize_context(context)
        result = Marshal.load(context)
        Novel::Context.new(deserializable_attributes(result))
      end

      def serialize_context(context)
        new_context = Novel::Context.new(serializable_attributes(context))
        Marshal.dump(new_context)
      end

      def serializable_attributes(context)
        unit_stub = UnitStub.new

        attributes = context.attributes.clone
        attributes[:step_results] = {}

        context.attributes[:step_results].each do |k,v|
          attributes[:step_results][k] = unit_stub if v == Dry::Monads::Unit
        end
        attributes[:compensation_step_results].each do |k,v|
          attributes[:compensation_step_results][k] = unit_stub if v == Dry::Monads::Unit
        end
        attributes
      end

      def deserializable_attributes(context)
        attributes = context.attributes.dup

        attributes[:step_results].each do |k,v|
          attributes[:step_results][k] = Dry::Monads::Unit if v.is_a?(UnitStub)
        end
        attributes[:compensation_step_results].each do |k,v|
          attributes[:compensation_step_results][k] = Dry::Monads::Unit if v.is_a?(UnitStub)
        end
        attributes
      end

      def find_context(saga_id)
        result = connection_pool.with { |r| r.get("novel.sagas.#{saga_id}") }
        result ? deserialize_context(result) : nil
      end

      def persist_context(saga_id, context)
        connection_pool.with { |r| r.set("novel.sagas.#{saga_id}", serialize_context(context)) }
        context
      end
    end
  end
end
