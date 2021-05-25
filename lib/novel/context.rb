require 'securerandom'

module Novel
  class Context
    INIT_SAGA_STATUS       = :init
    PROCESSING_SAGA_STATUS = :processing
    WAITING_SAGA_STATUS    = :waiting
    COMPLETED_SAGA_STATUS  = :completed

    attr_reader :id, :params, :last_competed_step, :last_competed_compensation_step

    def initialize(id:, params:, step_results: {}, compensation_step_results: {})
      @id = id
      @params = params

      @step_results = step_results
      @compensation_step_results = compensation_step_results

      @last_competed_step = nil
      @last_competed_compensation_step = nil

      @status = INIT_SAGA_STATUS
      @failed = false
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
