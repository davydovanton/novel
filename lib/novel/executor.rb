require 'novel/executor/activity_flow'
require 'novel/executor/compensation_flow'

module Novel
  class Executor
    include Dry::Monads[:result]

    attr_reader :container, :repository, :activity_flow_executor, :compensation_flow_executor

    def initialize(container:, repository:)
      @container = container
      @repository = repository

      @activity_flow_executor = Novel::Executor::ActivityFlow.new(container: container, repository: repository)
      @compensation_flow_executor = Novel::Executor::CompensationFlow.new(container: container, repository: repository)
    end

    def start_transaction(saga_id, params, first_step)
      context = repository.find_or_create_context(saga_id, params)
      state_machine = StateMachines::SagaStatus.build(state: context.saga_status)

      if state_machine.started?
        state_machine.wait
        context.update_saga_status(state_machine.state)
        repository.persist_context(context)
        return Success(status: :waiting, context: context) if first_step[:async]
      end

      Success(status: :pending, context: [context, state_machine])
    end

    def call_activity_flow(context, state_machine, steps)
      activity_flow_executor.call(context, state_machine, steps)
    end

    def call_compensation_flow(context, state_machine, steps)
      compensation_flow_executor.call(context, state_machine, steps)
    end

    def finish_transaction(context, state_machine)
    end
  end
end
