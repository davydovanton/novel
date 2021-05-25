require 'state_machines'

module Novel
  class StateMachines
    class TransactionStatus
      state_machine initial: :waiting do
        event :process do
          transition blank: :processing
        end

        event :complete do
          transition processing: :completed
        end

        event :wait do
          transition completed: :waiting
        end

      end
    end
  end
end
