require_relative '../support/failure_commands'

RSpec.describe 'Novel full flow with failure steps' do
  let(:saga) do
    Novel.compose(repository: :memory)
      .build(name: :booking)
      .register_step(:car,           activity: { command: FailureTest::ReserveCar.new, retry: 3 },          compensation: { command: FailureTest::CancelCar.new, retry: 3 })
      .register_step(:notify_hotel,  activity: { command: FailureTest::BookHotelProducer.new },             compensation: { command: FailureTest::CancelHotelHandler.new, async: true })
      .register_step(:handle_hotel,  activity: { command: FailureTest::BookHotelHandler.new, async: true }, compensation: { command: FailureTest::CancelHotelProducer.new })
      .register_step(:tools,         activity: { command: FailureTest::BookTools.new },                     compensation: { command: FailureTest::CancelTools.new })
      .register_step(:flight,        activity: { command: FailureTest::BookFlight.new },                    compensation: { command: FailureTest::CancelFlight.new })
      .build
  end

  it 'call failure saga with sync and async steps' do
    success_result = saga.call(params: { a: 1 })

    expect(success_result).to be_success
    expect(success_result.value![:status]).to eq(:waiting)

    expect(success_result.value![:context].last_completed_step).to eq(:notify_hotel)
    expect(success_result.value![:context].last_completed_compensation_step).to eq(nil)

    expect(success_result.value![:context].completed_steps).to eq([:car, :notify_hotel])
    expect(success_result.value![:context].completed_compensation_steps).to eq([])

    # "WAITING EVENT from hotel"

    failure_result = saga.call(saga_id: success_result.value![:context].id)
    expect(failure_result).to be_failure
    expect(failure_result.failure[:status]).to eq(:saga_failed)

    expect(failure_result.failure[:context].last_completed_step).to eq(:tools)
    expect(failure_result.failure[:context].last_completed_compensation_step).to eq(:handle_hotel)

    expect(failure_result.failure[:context].completed_steps).to eq([:car, :notify_hotel, :handle_hotel, :tools])
    expect(failure_result.failure[:context].completed_compensation_steps).to eq([:flight, :tools, :handle_hotel])

    # "WAITING COMPENSATION EVENT from hotel"

    new_failure_result = saga.call(saga_id: success_result.value![:context].id)

    expect(new_failure_result).to be_failure
    expect(new_failure_result.failure[:status]).to eq(:saga_failed)

    expect(new_failure_result.failure[:context].last_completed_step).to eq(:tools)
    expect(new_failure_result.failure[:context].last_completed_compensation_step).to eq(:car)

    expect(new_failure_result.failure[:context].completed_steps).to eq([:car, :notify_hotel, :handle_hotel, :tools])
    expect(new_failure_result.failure[:context].completed_compensation_steps).to eq([:flight, :tools, :handle_hotel, :notify_hotel, :car])
  end
end
