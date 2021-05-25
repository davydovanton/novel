module Novel
  class Container
    attr_reader :_container

    def initialize
      @_container = {}
    end

    def register(key, object)
      _container[key.to_s] = object
    end

    def resolve(key)
      _container[key.to_s]
    end
  end
end
