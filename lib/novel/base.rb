module Novel
  class Base
    attr_reader :logger, :repository

    REPOSITORIES = {
      memory: Repository.new(adapter: RepositoryAdapters::Memory.new)
    }

    def initialize(logger:, repository:, timeout:, **args)
      @logger = logger
      @repository = repository.is_a?(Symbol) ? REPOSITORIES[repository] : repository
      @timeout = timeout
    end

    def build(name:)
      WorkflowBuilder.new(name: :booking, repository: repository)
    end
  end
end
