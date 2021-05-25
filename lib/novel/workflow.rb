module Novel
  class Workflow
    attr_reader :raw, :activity_flow, :compensation_flow

    FINISH_STEP = :finish

    def initialize(raw:)
      @raw = raw
    end

    def activity_steps
      @activity_steps ||= raw.map { |step| { name: step[:name], async: step[:activity][:async] } }
    end

    def activity_steps_from(step)
      if step
        next_step_index = activity_flow.index(step) + 1
        remaining_steps = activity_flow[next_step_index..-1]
        activity_steps.select { |s, _| remaining_steps.include?(s[:name]) }
      else
        activity_steps
      end
    end

    def compensation_steps
      @compensation_steps ||= raw.reverse.map { |step| step[:compensation] ? { name: step[:name], async: step[:compensation][:async] } : nil }.compact
    end

    def compensation_steps_from(step)
      # TODO: question should I call compensation logic for failed step or should I call next step in the flow?

      first_compensation_step_index = calculate_compensation_index(next_compensation_step(step)[:name])
      remaining_steps = compensation_flow[first_compensation_step_index..-1]
      compensation_steps.select { |s, _| remaining_steps.include?(s[:name]) }
    end


    def next_activity_step(step_name)
      # activity_flow.include?(step_name)

      activity_steps.find { |s| s[:name] == get_next_by_index(activity_flow, activity_flow.index(step_name)) }
    end

    def next_compensation_step(step_name)
      # activity_flow.include?(step_name)

      compensation_steps.find { |s| s[:name] == get_next_by_index(compensation_flow, calculate_compensation_index(step_name)) }
    end

  private
    def activity_flow
      @activity_flow ||= raw.map { |step| step[:name] }
    end

    def compensation_flow
      @compensation_flow ||= raw.reverse.map { |step| step[:compensation] ? step[:name] : nil }
    end

    def calculate_compensation_index(step_name)
      compensation_flow.include?(step_name) ? compensation_flow.index(step_name) : activity_flow.reverse.index(step_name)
    end

    def get_next_by_index(list, step_index)
      next_index = step_index + 1
      if next_index < list.count
        list[next_index] || get_next_by_index(list, step_index + 1)
      else
        FINISH_STEP
      end
    end
  end
end
