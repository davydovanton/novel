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
        end

        Success(status: :finished, context: context)
      end

    private

      def execut_step(context, state_machine, step, next_step)
        result = container.resolve("#{step[:name]}.activity").call(context)

        if result.failure?
          state_machine.ruin
          context.save_compensation_state(step[:name], result.failure)
          repository.persist_context(context)

          return Failure(result: result, context: context)
        end

        status = transaction_status(next_step, state_machine)

        context.save_state(step[:name], result.value!)
        repository.persist_context(context)

        Success(status: status, context: context)
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
