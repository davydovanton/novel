# Novel

PoC library for orchestration saga pattern. This library can provide DSL for building orchestration objects for your sagas.

The main reason why Novel exists is personal motivation to understand SAGA pattern better and make a great tool for orchestration SAGAs in ruby.

Key concepts:

- Immutable objects only.
- No global state. It means that you need to use IoC or containers by yourself.
- Context object as a state of SAGA and only one way to get data in each command.
- Monads as a result value for each step and full saga flow.

Dependencies:

- `dry-monads` as a result values for everything. Also, saga commands works only with result monads;
- `dry-types` as a DTO builder for context object;
- `state_machines` gem as a main state machine implementation.

## Installation

Add this line to your application's Gemfile:
```ruby
gem 'novel'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install novel

## Usage

You can see all examples in https://github.com/davydovanton/novel/tree/master/examples folder.

### Commands
The main object of SAGA. Each command should follow specific rules:

- One command - one business step/transaction.
- Result of each object should be a Result monad (success/failure). When the command returns failure monad Novel starts compensation flow.
- Each command should take only one argument - `context` object. In context object you can get initial params + result of each step (activity and compensation).

### Building SAGA
For building orchestration you need to use this DSL:

```ruby
saga = Novel.compose(logger: Logger.new(STDOUT), repository: :memory | custom_repository_object)
      .build(name: :booking)
      .register_step(:car,           activity: { command: ReserveCar.new, retry: 3 },          compensation: { command: CancelCar.new, retry: 3 })
      .register_step(:notify_hotel,  activity: { command: BookHotelProducer.new },             compensation: { command: CancelHotelHandler.new, async: true })
      .register_step(:handle_hotel,  activity: { command: BookHotelHandler.new, async: true }, compensation: { command: CancelHotelProducer.new })
      .register_step(:flight,        activity: { command: BookFlight.new },                    compensation: { command: CancelFlight.new })
      .build

```
#### Sync steps
Sync steps allow you to call the next step without waiting. It means that each step will call the next sync step after self-complete. It's similar to regular interactor/DO notation/dry-transaction flow. To make the sync step you don't need anything. Just put command object to `command` option:

```ruby
# will create tools step with sync activity command and sync compensation command
.register_step(:tools, activity: { command: BookTools.new }, compensation: { command: CancelTools.new })
```

#### Async steps
Async steps allow you to wait any time between steps. It's really useful when you're waiting for an event from another part of your system. For example, the activity command produces an event, and the next step waiting when the system consumes a specific event from the message broker. For make async step you just need to add `async: true` option to the command:

```ruby
# will create two steps:
#   - notify_hotel step with sync activity command and async compensation command 
#   - handle_hotel step with async activity command and sync compensation command
.register_step(:notify_hotel,  activity: { command: BookHotelProducer.new },             compensation: { command: CancelHotelHandler.new, async: true })
.register_step(:handle_hotel,  activity: { command: BookHotelHandler.new, async: true }, compensation: { command: CancelHotelProducer.new })
```

When you working with async steps you need to manually call the saga orchestration object every time to continue flow execution. For the next call you need to send `saga id` instead of params:

```ruby

result = saga.call(params) # first orchestration call
# => Success(Context(id: uuid))
saga.call(result.value!.id) # second call for saga flow. In this case you need to put saga id form context object to continue execution flow
```

### Context object
Context object provides two options:
1. Getting state of saga flow: it means that you can get the current state of saga execution, returned values for each step, and other useful information.
2. Continue working with the same saga flow in a different place (other instance of an application or other part of your system). We can do it because each context object can persist in any DB. Novel allows persisting context in memory or redis.

For more information check the source code of the context object (https://github.com/davydovanton/novel/blob/master/lib/novel/context.rb)

### Adapters

Novel allows you to persist context in any DB that you want. I implemented memory (only for sync steps) and redis (for sync and async steps). 

You can create a custom repository adapter. For this check redis implementation (https://github.com/davydovanton/novel/blob/master/lib/novel/repository_adapters/redis.rb) and redis example (https://github.com/davydovanton/novel/tree/master/examples/redis) from source code.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/davydovanton/novel. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Novel project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/davydovanton/novel/blob/master/CODE_OF_CONDUCT.md).
