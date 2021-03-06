module Novel
  class Base
    attr_reader :logger, :repository

    REPOSITORIES = {
      memory: SagaRepository.new(adapter: RepositoryAdapters::Memory.new)
    }

    def initialize(logger:, repository:, timeout:, **args)
      @logger = logger
      @repository = repository.is_a?(Symbol) ? REPOSITORIES[repository] : repository
      raise_invalid_repository_error!(repository) unless @repository
      @timeout = timeout
    end

    def build(name:)
      WorkflowBuilder.new(name: name, repository: repository)
    end

    private

    def raise_invalid_repository_error!(repository)
      raise InvalidRepositoryError.new(
        "Repository '#{repository}' does not exist in Novel. Please, use custom object instead."
      )
    end
  end
end
