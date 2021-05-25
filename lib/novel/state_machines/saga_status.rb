require 'state_machines'

module Novel
  class StateMachines
    class SagaStatus
      state_machine initial: :started do
        event :wait do
          transition [:started, :processing] => :waiting
          transition processing_compensation: :waiting_compensation
        end

        event :process do
          transition [:started, :waiting] => :processing
          transition waiting_compensation: :processing_compensation
        end

        # CONTEXT: "fail" reserved for private api of state machine
        event :ruin do
          transition processing: :processing_compensation
        end

        event :complete do
          transition [:processing_compensation, :processing] => :completed
        end
      end

      def self.build(state: nil)
        sm = self.new
        sm.state = state.to_s if state
        sm
      end
    end
  end
end
