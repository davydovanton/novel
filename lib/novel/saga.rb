require "novel/context"

module Novel
  class Saga
    include Dry::Monads[:result]

    attr_reader :workflow, :executor

    def initialize(name:, workflow:, executor:)
      @name = name

      @workflow = workflow
      @executor = executor
    end

    def call(params: {}, saga_id: SecureRandom.uuid)
      start_result = executor.start_transaction(saga_id, params, workflow.activity_steps.first)
      return start_result if start_result.value![:status] == :waiting

      context, saga_state = start_result.value![:context]

      if context.success?
        activity_flow_result = executor.call_activity_flow(context, saga_state, workflow.activity_steps_from(context.last_competed_step))

        activity_flow_result.or do |error_result|
          compensation_result = sync_compensation_result_for(error_result[:context], saga_state, error_result)

          Failure(status: :saga_failed, compensation_result: compensation_result, context: compensation_result.value![:context])
        end
      else
        compensation_steps = workflow.compensation_steps_from(context.last_competed_compensation_step)
        compensation_result = executor.call_compensation_flow(context, saga_state, compensation_steps)

        Failure(status: :saga_failed, compensation_result: compensation_result, context: compensation_result.last.value![:context])
      end
    end

  private

    def sync_compensation_result_for(context, saga_state, error_result)
      if workflow.next_compensation_step(context.last_competed_compensation_step)[:async]
        # TODO: saga_state.wait
        Success(error_result: error_result, context: context)
      else
        executor.call_compensation_flow(context, saga_state, workflow.compensation_steps_from(context.last_competed_compensation_step))
      end
    end
  end
end
