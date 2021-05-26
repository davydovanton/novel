module Novel
  module RepositoryAdapters
    class Redis
      attr_reader :connection_pool

      def initialize(connection_pool:)
        @connection_pool = connection_pool
      end

      def find_context(saga_id)
        result = connection_pool.with { |r| r.get("novel.sagas.#{saga_id}") }
        result ? Marshal.load(result) : nil
      end

      def persist_context(saga_id, context)
        connection_pool.with { |r| r.set("novel.sagas.#{saga_id}", Marshal.dump(context)) }
        context
      end
    end
  end
end
