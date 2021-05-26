require_relative './saga'

# TODO: please, use saga id from redis_success_saga_1.rb file for make it works (you can find this value in the context object)
new_result = SAGA.call(saga_id: '5db85904-b359-44ed-9672-a9cb6015676c')
pp new_result
