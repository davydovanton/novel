require 'securerandom'
require 'dry/monads'

module Novel
  class Saga
    include Dry::Monads[:result]

    attr_reader :container, :workflow

    def initialize(name:, workflow:, container: Container.new, description: '')
      @name = name
      @description = description

      @workflow = workflow
      @container = container
    end

    def call(params: {}, saga_id: SecureRandom.uuid)
      result = flow_execution(params)

      if result.failure?
        workflow.compensation_steps_from(result.failure[:step]).each do |step|
          result = container.resolve("#{step}.compensation").call(params)
        end
      end

      result
    end

  private

    def flow_execution(params)
      workflow.activity_flow.each do |step|
        result = container.resolve("#{step}.activity").call(params)

        if result.failure?
          return Failure(step: step, result: result)
        end
      end

      Success(:finish)
    end
  end
end
