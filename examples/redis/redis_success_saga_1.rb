require_relative './saga'

result = SAGA.call(params: { a: 1 })
pp result
