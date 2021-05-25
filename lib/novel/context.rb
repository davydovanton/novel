require 'securerandom'

module Novel
  class Context
    attr_reader :id, :params, :last_competed_step, :last_competed_compensation_step, :saga_status

    def initialize(id:, params:, step_results: {}, compensation_step_results: {})
      @id = id
      @params = params

      @step_results = step_results
      @compensation_step_results = compensation_step_results

      @last_competed_step = nil
      @last_competed_compensation_step = nil

      @saga_status = StateMachines::SagaStatus.new
      # @current_transaction_status = StateMachines::TransactionStatus.new
      @failed = false
    end

    def success?
      !@failed
    end

    def failed?
      @failed
    end

    def save_state(step, result)
      @last_competed_step = step
      @step_results[step] = result
    end

    def save_compensation_state(step, result)
      @failed = true
      @last_competed_compensation_step = step
      @compensation_step_results[step] = result
    end

    def step(step)
      @step_results[step]
    end

    def completed_steps
      @step_results.keys
    end

    def compensation_step(step)
      @compensation_step_results[step]
    end

    def completed_compensation_steps
      @compensation_step_results.keys
    end
  end
end
