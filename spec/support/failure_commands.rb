require 'dry/monads'

module FailureTest
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
end
