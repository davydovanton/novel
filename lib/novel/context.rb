require 'securerandom'
require 'dry-struct'

module Novel
  class Context  < Dry::Struct
    module Types
      include Dry.Types()

      Bool = True | False
    end

    INIT_SAGA_STATUS = 'started'

    attribute :id, Types::String
    attribute :params, Types::Hash.default({})
    attribute :saga_status, Types::String.default(INIT_SAGA_STATUS)

    attribute? :last_competed_step, Types::Symbol
    attribute :step_results, Types::Hash.default({})

    attribute? :last_competed_compensation_step, Types::Symbol
    attribute :compensation_step_results, Types::Hash.default({})

    attribute :failed, Types::Bool.default(false)

    def success?
      !attributes[:failed]
    end

    def failed?
      attributes[:failed]
    end

    def step(step)
      attributes[:step_results][step]
    end

    def completed_steps
      attributes[:step_results].keys
    end

    def compensation_step(step)
      attributes[:compensation_step_results][step]
    end

    def completed_compensation_steps
      attributes[:compensation_step_results].keys
    end
  end
end
