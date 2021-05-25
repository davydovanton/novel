module Novel
  class Executor
    class ActivityFlow
      include Dry::Monads[:result]

      attr_reader :container, :repository

      def initialize(container:, repository:)
        @container = container
        @repository = repository
      end

      def call(context, state_machine, steps)
        steps.each_with_index do |step, index|
          result = execut_step(context, state_machine, step, steps[index + 1])

          return result if result.failure? || result.value![:status] == :waiting

          context = result.value![:context]
          result
        end

        Success(status: :finished, context: context)
      end

    private

      def execut_step(context, state_machine, step, next_step)
        result = container.resolve("#{step[:name]}.activity").call(context)

        if result.failure?
          state_machine.ruin

          new_context = repository.persist_context(
            context,
            failed: true,
            saga_status: state_machine.state,
            last_competed_compensation_step: step[:name],
            compensation_step_results: context.to_h[:compensation_step_results].merge(step[:name] => result.failure)
          )

          return Failure(result: result, context: new_context)
        end

        status = transaction_status(next_step, state_machine)

        Success(
          status: status,
          context: repository.persist_context(
            context,
            saga_status: state_machine.state,
            last_competed_step: step[:name],
            step_results: context.to_h[:step_results].merge(step[:name] => result.value!)
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
