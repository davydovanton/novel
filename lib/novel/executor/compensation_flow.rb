module Novel
  class Executor
    class CompensationFlow
      include Dry::Monads[:result]

      attr_reader :container, :repository

      def initialize(container:, repository:)
        @container = container
        @repository = repository
      end

      def call(context, state_machine, steps)
        steps.each_with_index.map do |step, index|
          result = execut_step(context, state_machine, step, steps[index + 1])

          if result.value![:status] == :waiting
            return result
          else
            result
          end
        end
      end

    private

      def execut_step(context, state_machine, step, next_step)
        result = container.resolve("#{step[:name]}.compensation").call(context)

        status = transaction_status(next_step, state_machine)
        context.save_compensation_state(step[:name], result.value!)
        repository.persist_context(context)

        Success(status: status, result: result, context: context)
      end

      def transaction_status(next_step, state_machine)
        if next_step&.fetch(:async) 
          state_machine.wait

          :waiting
        else
          :processing
        end
      end
    end
  end
end
