module SimpleLock
  class MemoryAdapter
    def initialize
      @store = {}
    end

    def read(name)
      record = @store[name]

      record[:value] if record[:created_at] + record[:ttl] < Time.now.utc
    end

    def write(name, value:, expires_in:)
      record = {name: name, value: value, created_at: Time.now.utc}
      @store[name] = value
    end

    def delete(name)
      @store.delete name
      @ttl.delete name
    end
  end
end
