require 'logger'
require 'dry/monads'
require 'securerandom'

require 'novel/state_machines/saga_status'
require 'novel/state_machines/transaction_status'

require 'novel/container'
require 'novel/workflow_builder'
require 'novel/workflow'
require 'novel/executor'
require 'novel/saga_repository'
require 'novel/saga'
require 'novel/base'
require 'novel/version'

module Novel
  class Error < StandardError; end
  class InvalidRepositoryError < Error; end

  BASE_LOGGER = Logger.new(STDOUT)
  ONE_MINUTE = 60
  MEMORY_REPOSITORY = SagaRepository.new(adapter: RepositoryAdapters::Memory.new)

  def self.compose(repository: MEMORY_REPOSITORY, logger: BASE_LOGGER, timeout: ONE_MINUTE, **args)
    Base.new(repository: repository, logger: logger, timeout: timeout, **args)
  end
end
