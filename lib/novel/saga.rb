require 'securerandom'

module Novel
  class Saga
    attr_reader :container, :workflow

    def initialize(name:, workflow:, container: Container.new, description: '')
      @name = name
      @description = description

      @workflow = workflow
      @container = container
    end

    def call(params: {}, saga_id: SecureRandom.uuid)
      workflow.activity_flow.each do |step|
        container.resolve("#{step}.activity").call(params)
      end
    end
  end
end
