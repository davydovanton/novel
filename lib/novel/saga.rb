require 'securerandom'
require 'dry/monads'

require "novel/context"

module Novel
  class Saga
    include Dry::Monads[:result]

    attr_reader :container, :workflow

    def initialize(name:, workflow:, container: Container.new)
      @name = name

      @workflow = workflow
      @container = container
    end

    def call(params: {}, saga_id: SecureRandom.uuid, context: nil)
      context = context || Context.new(id: saga_id, params: params)

      activity_flow_execution(context).or do |error_result|
        return Failure(
          status: :saga_failed,
          compensation_result: compensation_flow_execution(error_result, context),
          context: context
        )
      end
    end

  private

    def activity_flow_execution(context)
      workflow.activity_steps_from(context.last_competed_step).each do |step_information|
        result = container.resolve("#{step_information[:name]}.activity").call(context)

        if result.failure?
          return Failure(step: step_information[:name], result: result, context: context)
        end

        context.save_state(step_information[:name], result.value!)
        return Success(status: :waiting, context: context) if step_information[:async]
      end

      Success(status: :finish, context: context)
    end

    def compensation_flow_execution(result, context)
      workflow.compensation_steps_from(result[:step]).map do |step|
        result = container.resolve("#{step}.compensation").call(context)

        context.save_compensation_state(step, result.value!)
        result
      end
    end
  end
end
