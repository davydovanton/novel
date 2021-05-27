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
          result = execute_step(context, state_machine, step, steps[index + 1])
          context = result.value![:context]

          if result.value![:status] == :waiting
            return result
          else
            result
          end
        end
      end

    private

      def execute_step(context, state_machine, step, next_step)
        result = container.resolve("#{step[:name]}.compensation").call(context)
        status = transaction_status(next_step, state_machine)

        Success(
          status: status,
          result: result,
          context: repository.persist_context(
            context,
            failed: true,
            saga_status: state_machine.state,
            last_completed_compensation_step: step[:name],
            compensation_step_results: context.to_h[:compensation_step_results].merge(step[:name] => result.value!)
          )
        )
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
