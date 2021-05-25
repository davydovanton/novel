module Novel
  class WorkflowBuilder
    attr_reader :name, :raw_workflow, :repository

    def initialize(name:, repository:, raw_workflow: [])
      @name = name
      @raw_workflow = raw_workflow
      @repository = repository
    end

    def register_step(name, activity:, compensation: nil)
      self.class.new(
        name: name,
        repository: repository,
        raw_workflow: raw_workflow + [{ name: name, activity: activity, compensation: compensation }]
      )
    end

    def build
      Saga.new(
        name: name,
        workflow: Workflow.new(raw: raw_workflow),
        repository: repository,
        container: build_container
      )
    end

  private

    def build_container
      container = Container.new
      raw_workflow.each do |step|
        container.register("#{step[:name]}.activity", step[:activity][:command])
        container.register("#{step[:name]}.compensation", step[:compensation][:command])
      end
      container
    end
  end
end
