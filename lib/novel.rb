require 'logger'

require 'novel/container'
require 'novel/workflow_builder'
require 'novel/workflow'
require 'novel/repository'
require 'novel/saga'
require 'novel/base'
require 'novel/version'

module Novel
  class Error < StandardError; end

  BASE_LOGGER = Logger.new(STDOUT)
  ONE_MINUTE = 60
  MEMORY_REPOSITORY = Repository.new(adapter: RepositoryAdapters::Memory.new)

  def self.compose(repository: MEMORY_REPOSITORY, logger: BASE_LOGGER, timeout: ONE_MINUTE, **args)
    Base.new(repository: repository, logger: logger, timeout: timeout, **args)
  end
end
