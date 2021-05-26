require "novel"
require 'dry/monads'

class BaseStep
  include Dry::Monads[:result]

  def call(context)
    puts "Step #{self.class}, context: #{context.inspect}"
    puts
    Success(result: rand(1..100))
  end
end

class ReserveCar < BaseStep
  def call(context)
    # sleep(rand(10))
    puts "Step #{self.class}, context: #{context.inspect}"
    puts
    Success(result: rand(1..100))
  end
end

class BookHotelProducer < BaseStep; end
class BookHotelHandler < BaseStep; end
class BookTools < BaseStep; end

class BookFlight < BaseStep
  def call(context)
    puts "!!! Step #{self.class} failed"
    puts
    Failure(failure_result: rand(1..100))
  end
end

class CancelCar < BaseStep
  def call(context)
    # sleep(rand(10))
    puts "Step #{self.class}, context: #{context.inspect}"
    puts
    Success(result: rand(1..100))
  end
end

class CancelHotelProducer < BaseStep; end
class CancelHotelHandler < BaseStep; end
class CancelTools < BaseStep; end
class CancelFlight < BaseStep; end

saga = Novel.compose(logger: Logger.new(STDOUT), repository: :memory, timeouts: 5) # timeout in seconds
      .build(name: :booking)
      .register_step(:car,           activity: { command: ReserveCar.new, retry: 3 },          compensation: { command: CancelCar.new, retry: 3 })
      .register_step(:notify_hotel,  activity: { command: BookHotelProducer.new },             compensation: { command: CancelHotelHandler.new, async: true })
      .register_step(:handle_hotel,  activity: { command: BookHotelHandler.new, async: true }, compensation: { command: CancelHotelProducer.new })
      .register_step(:tools,         activity: { command: BookTools.new },                     compensation: { command: CancelTools.new })
      .register_step(:flight,        activity: { command: BookFlight.new },                    compensation: { command: CancelFlight.new })
      .build

success_result = saga.call(params: { a: 1 })

puts '*'*80
puts "WAITING EVENT"
puts '*'*80

saga.call(saga_id: success_result.value![:context].id)

puts '*'*80
puts "WAITING EVENT"
puts '*'*80

new_result = saga.call(saga_id: success_result.value![:context].id)
pp new_result.failure
