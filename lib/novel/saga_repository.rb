require 'novel/repository_adapters/memory'

module Novel
  class SagaRepository
    attr_reader :adapter

    def initialize(adapter: RepositoryAdapters::Memory.new)
      @adapter = adapter
    end

    def find_or_create_context(saga_id, params)
      adapter.find_context(saga_id) || adapter.persist_context(saga_id, Context.new(id: saga_id, params: params))
    end

    def persist_context(context, **params)
      new_context = Context.new({ **context.to_h, **params })
      adapter.persist_context(context.id, new_context)
      new_context
    end
  end
end
