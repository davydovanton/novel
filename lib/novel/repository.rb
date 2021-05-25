require 'novel/repository_adapters/memory'

module Novel
  class Repository
    attr_reader :adapter

    def initialize(adapter: RepositoryAdapters::Memory.new)
      @adapter = adapter
    end

    def find_or_create_context(saga_id, params)
      find_context(saga_id) || persist_context(saga_id, Context.new(id: saga_id, params: params))
    end

    def find_context(saga_id)
      adapter.find_context(saga_id)
    end

    def persist_context(saga_id, context)
      adapter.persist_context(saga_id, context)
    end
  end
end
