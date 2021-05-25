module Novel
  # TODO: class TransactionExecutor
  class Executor
    include Dry::Monads[:result]

    attr_reader :container, :repository

    def initialize(container:, repository:)
      @container = container
      @repository = repository
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
      steps.each_with_index do |step, index|
        result = call_activity_transaction(context, state_machine, step, steps[index + 1])
        if result.failure?
          return result
        elsif result.value![:status] == :waiting
          return result
        end
      end

      Success(status: :finished, context: context)
    end

    def call_activity_transaction(context, state_machine, step, next_step)
      result = container.resolve("#{step[:name]}.activity").call(context)

      if result.failure?
        state_machine.ruin
        context.save_compensation_state(step[:name], result.failure)
        repository.persist_context(context)

        return Failure(result: result, context: context)
      end

      status = transaction_status(next_step, state_machine)

      context.save_state(step[:name], result.value!)
      repository.persist_context(context)

      Success(status: status, context: context)
    end

    def call_compensation_flow(context, state_machine, steps)
      steps.each_with_index.map do |step, index|
        result = call_compensation_transaction(context, state_machine, step, steps[index + 1])

        if result.value![:status] == :waiting
          return result
        else
          result
        end
      end
    end

    def call_compensation_transaction(context, state_machine, step, next_step)
      result = container.resolve("#{step[:name]}.compensation").call(context)

      status = transaction_status(next_step, state_machine)
      context.save_compensation_state(step[:name], result.value!)
      repository.persist_context(context)

      Success(status: status, result: result, context: context)
    end

    def sync_compensation_transaction(context, state_machine, step, error_result)
    end

    def finish_transaction(context, state_machine)
    end

  private

    def transaction_status(next_step, state_machine)
      if next_step&.fetch(:async) 
        state_machine.wait

        :waiting
      else
        :processing
      end
    end
  end
end
