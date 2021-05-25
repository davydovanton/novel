require 'securerandom'

module Novel
  class Context
    attr_reader :id, :params, :saga_status, :last_competed_step, :last_competed_compensation_step, :saga_status

    INIT_SAGA_STATUS = :started

    def initialize(id:, params:, saga_status: INIT_SAGA_STATUS, last_competed_step: nil, last_competed_compensation_step: nil, step_results: {}, compensation_step_results: {}, failed: false)
      @id = id
      @params = params
      @saga_status = saga_status

      @last_competed_step = last_competed_step
      @step_results = step_results

      @compensation_step_results = compensation_step_results
      @last_competed_compensation_step = last_competed_compensation_step

      @failed = failed
    end

    def to_h
      {
        id: @id,
        params: @params,
        saga_status: @saga_status,
        last_competed_step: @last_competed_step,
        step_results: @step_results,
        last_competed_compensation_step: @last_competed_compensation_step,
        compensation_step_results: @compensation_step_results
      }
    end

    def success?
      !@failed
    end

    def failed?
      @failed
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
