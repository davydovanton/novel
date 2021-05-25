require "novel/context"

module Novel
  class Saga
    include Dry::Monads[:result]

    attr_reader :workflow, :repository, :executor

    def initialize(name:, workflow:, repository:, executor:)
      @name = name

      @workflow = workflow
      @repository = repository
      @executor = executor
    end

    def call(params: {}, saga_id: SecureRandom.uuid)
      context = repository.find_or_create_context(saga_id, params)

      if context.success?
        if context.saga_status.started?
          context.saga_status.wait
          return Success(status: :waiting, context: context) if workflow.activity_steps.first[:async]
        end

        activity_flow_result = activity_flow_execution(context)

        activity_flow_result.or do |error_result|
          compensation_result = sync_compensation_result_for(context) || error_result
          Failure(status: :saga_failed, compensation_result: compensation_result, context: context)
        end
      else
        compensation_result = compensation_flow_execution(context)
        Failure(status: :saga_failed, compensation_result: compensation_result, context: context)
      end
    end

  private

    def activity_flow_execution(context)
      workflow.activity_steps_from(context.last_competed_step).each do |step|
        result = executor.call_activity_transaction(step, context)
        return result if result.failure? || result.value![:status] == :waiting
      end

      Success(status: :finished, context: context)
    end

    def compensation_flow_execution(context)
      workflow.compensation_steps_from(context.last_competed_compensation_step).map do |step|
        result = executor.call_compensation_transaction(step, context)

        return result if result.value![:status] == :waiting
      end
    end

    def sync_compensation_result_for(context)
      compensation_flow_execution(context) unless workflow.next_compensation_step(context.last_competed_compensation_step)[:async]
    end
  end
end
