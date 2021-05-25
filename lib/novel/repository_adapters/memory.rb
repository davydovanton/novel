module Novel
  module RepositoryAdapters
    class Memory
      def initialize
        @store = {}
      end

      def find_context(saga_id)
        @store[saga_id]
      end

      def persist_context(saga_id, context)
        @store[saga_id] = context
        context
      end
    end
  end
end
