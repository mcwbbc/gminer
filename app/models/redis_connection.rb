class RedisConnection

  class << self
    def db
      @redis ||= Redis.new(:thread_safe => true)
    end
  end

end
