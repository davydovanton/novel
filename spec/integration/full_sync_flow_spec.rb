require_relative '../support/success_commands'

RSpec.describe 'Novel full flow with only sync steps' do
  let(:saga) do
    Novel.compose(repository: :memory)
      .build(name: :booking)
      .register_step(:car,    activity: { command: SuccessTest::ReserveCar.new }, compensation: { command: SuccessTest::CancelCar.new })
      .register_step(:tools,  activity: { command: SuccessTest::BookTools.new }, compensation: { command: SuccessTest::CancelTools.new })
      .register_step(:flight, activity: { command: SuccessTest::BookFlight.new }, compensation: { command: SuccessTest::CancelFlight.new })
      .build
  end

  it 'call failure saga with sync and async steps' do
    result = saga.call(params: { a: 1 })

    expect(result).to be_success
    expect(result.value![:status]).to eq(:finished)

    expect(result.value![:context].last_competed_step).to eq(:flight)
    expect(result.value![:context].last_competed_compensation_step).to eq(nil)

    expect(result.value![:context].completed_steps).to eq([:car, :tools, :flight])
    expect(result.value![:context].completed_compensation_steps).to eq([])
  end
end
