module Novel
  class Executor
    include Dry::Monads[:result]

    attr_reader :workflow, :container, :repository

    def initialize(workflow:, container:, repository:)
      @workflow = workflow
      @container = container
      @repository = repository
    end

    def call_activity_transaction(step, context)
      result = container.resolve("#{step[:name]}.activity").call(context)

      if result.failure?
        context.save_compensation_state(step[:name], result.failure)
        repository.persist_context(context.id, context)

        return Failure(result: result, context: context)
      end

      context.save_state(step[:name], result.value!)
      repository.persist_context(context.id, context)

      status = workflow.next_activity_step(step[:name])&.fetch(:async) ? :waiting : :processing
      Success(status: status, context: context)
    end

    def call_compensation_transaction(step, context)
      result = container.resolve("#{step[:name]}.compensation").call(context)
      context.save_compensation_state(step[:name], result.value!)
      repository.persist_context(context.id, context)

      status = workflow.next_compensation_step(step[:name])&.fetch(:async) ? :waiting : :processing
      Success(status: status, result: result, context: context)
    end
  end
end
