module Novel
  class Workflow
    attr_reader :raw, :activity_flow, :compensation_flow

    FINISH_STEP = :finish

    def initialize(raw:)
      @raw = raw
    end

    def activity_flow
      @activity_flow ||= raw.map { |step| step[:name] }
    end

    def compensation_flow
      @compensation_flow ||= raw.reverse.map { |step| step[:compensation] ? step[:name] : nil }
    end

    def next_activity_step(step_name)
      # activity_flow.include?(step_name)

      get_next_by_index(activity_flow, activity_flow.index(step_name))
    end

    def next_compensation_step(step_name)
      if compensation_flow.include?(step_name)
        get_next_by_index(compensation_flow, compensation_flow.index(step_name))
      else
        # activity_flow.include?(step_name)

        get_next_by_index(compensation_flow, activity_flow.reverse.index(step_name))
      end
    end


  private

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
