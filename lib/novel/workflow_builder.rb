module Novel
  class WorkflowBuilder
    attr_reader :name, :description, :raw_workflow

    def initialize(name:, description: '', raw_workflow: [])
      @name = name
      @description = description
      @raw_workflow = raw_workflow
    end

    def register_step(name, activity:, compensation: nil)
      self.class.new(
        name: name,
        description: description,
        raw_workflow: raw_workflow + [{ name: name, activity: activity, compensation: compensation }]
      )
    end

    def build
      Saga.new(
        name: name,
        description: description,
        workflow: Workflow.new(raw: raw_workflow),
        container: build_container
      )
    end

  private

    def build_container
      container = Container.new
      raw_workflow.each do |step|
        container.register("#{step[:name]}.activity", step[:activity])
        container.register("#{step[:name]}.compensation", step[:compensation])
      end
      container
    end
  end
end
