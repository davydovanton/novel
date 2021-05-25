require_relative '../support/success_commands'

RSpec.describe 'Novel full flow with only async steps' do
  let(:saga) do
    Novel.compose(repository: :memory)
      .build(name: :booking)
      .register_step(:car,           activity: { command: SuccessTest::ReserveCar.new, async: true }, compensation: { command: SuccessTest::CancelCar.new })
      .register_step(:tools,         activity: { command: SuccessTest::BookTools.new, async: true }, compensation: { command: SuccessTest::CancelTools.new })
      .register_step(:flight,        activity: { command: SuccessTest::BookFlight.new, async: true }, compensation: { command: SuccessTest::CancelFlight.new })
      .build
  end

  it 'call failure saga with sync and async steps' do
    result = saga.call(params: { a: 1 })

    expect(result).to be_success
    expect(result.value![:status]).to eq(:waiting)

    expect(result.value![:context].last_competed_step).to eq(nil)
    expect(result.value![:context].last_competed_compensation_step).to eq(nil)

    expect(result.value![:context].completed_steps).to eq([])
    expect(result.value![:context].completed_compensation_steps).to eq([])

    # "WAITING EVENT"

    second_result = saga.call(saga_id: result.value![:context].id)
    expect(second_result).to be_success
    expect(second_result.value![:status]).to eq(:waiting)

    expect(second_result.value![:context].last_competed_step).to eq(:car)
    expect(second_result.value![:context].last_competed_compensation_step).to eq(nil)

    expect(second_result.value![:context].completed_steps).to eq([:car])
    expect(second_result.value![:context].completed_compensation_steps).to eq([])

    # "WAITING EVENT"

    third_result = saga.call(saga_id: result.value![:context].id)

    expect(third_result).to be_success
    expect(third_result.value![:status]).to eq(:waiting)

    expect(third_result.value![:context].last_competed_step).to eq(:tools)
    expect(third_result.value![:context].last_competed_compensation_step).to eq(nil)

    expect(third_result.value![:context].completed_steps).to eq([:car, :tools])
    expect(third_result.value![:context].completed_compensation_steps).to eq([])

    # "WAITING EVENT"

    fourth_result = saga.call(saga_id: result.value![:context].id)

    expect(fourth_result).to be_success
    expect(fourth_result.value![:status]).to eq(:finished)

    expect(fourth_result.value![:context].last_competed_step).to eq(:flight)
    expect(fourth_result.value![:context].last_competed_compensation_step).to eq(nil)

    expect(fourth_result.value![:context].completed_steps).to eq([:car, :tools, :flight])
    expect(fourth_result.value![:context].completed_compensation_steps).to eq([])
  end
end
