require "novel"
require 'dry/monads'

require 'redis'
require 'connection_pool'

class BaseStep
  include Dry::Monads[:result]

  def call(context)
    puts "Step #{self.class}, context: #{context.inspect}"
    puts
    Success(result: rand(1..100))
  end
end

class ReserveCar < BaseStep; end
class BookHotelProducer < BaseStep; end
class BookHotelHandler < BaseStep; end
class BookTools < BaseStep; end
class BookFlight < BaseStep; end

class CancelCar < BaseStep; end
class CancelHotelProducer < BaseStep; end
class CancelHotelHandler < BaseStep; end
class CancelTools < BaseStep; end
class CancelFlight < BaseStep; end

redis = ConnectionPool.new { Redis.new }
redis_adapter = Novel::RepositoryAdapters::Redis.new(connection_pool: redis)
repository = Novel::SagaRepository.new(adapter: redis_adapter)

SAGA = Novel.compose(logger: Logger.new(STDOUT), repository: repository, timeouts: 5) # timeout in seconds
      .build(name: :booking)
      .register_step(:car,           activity: { command: ReserveCar.new, retry: 3 },          compensation: { command: CancelCar.new, retry: 3 })
      .register_step(:notify_hotel,  activity: { command: BookHotelProducer.new },             compensation: { command: CancelHotelHandler.new, async: true })
      .register_step(:handle_hotel,  activity: { command: BookHotelHandler.new, async: true }, compensation: { command: CancelHotelProducer.new })
      .register_step(:tools,         activity: { command: BookTools.new },                     compensation: { command: CancelTools.new })
      .register_step(:flight,        activity: { command: BookFlight.new },                    compensation: { command: CancelFlight.new })
      .build
