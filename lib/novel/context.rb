require 'securerandom'

module Novel
  class Context
    attr_reader :id, :params

    def initialize(id:, params:, step_results: {})
      @id = id
      @params = params
      @step_results = step_results
    end

    def step_result(step, result)
      @step_results[step] = result
    end

    def step(step)
      step_results[step]
    end
  end
end
