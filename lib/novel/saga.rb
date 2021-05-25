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

    def call(params: {}, saga_id: SecureRandom.uuid)
      context = Context.new(id: saga_id, params: params)

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
      workflow.activity_flow.each do |step|
        result = container.resolve("#{step}.activity").call(context)

        if result.failure?
          return Failure(step: step, result: result, context: context)
        end

        context.step_result(step, result.value!)
      end

      Success(status: :finish, context: context)
    end

    def compensation_flow_execution(result, context)
      workflow.compensation_steps_from(result[:step]).map do |step|
        container.resolve("#{step}.compensation").call(context)
      end
    end
  end
end
