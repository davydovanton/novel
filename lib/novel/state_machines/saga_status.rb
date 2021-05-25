require 'state_machines'

module Novel
  class StateMachines
    class SagaStatus
      state_machine initial: :started do
        event :wait do
          transition [:started, :processing] => :waiting
        end

        event :process do
          transition [:started, :waiting] => :processing
        end

        event :complete do
          transition processing: :completed
        end
      end
    end
  end
end
