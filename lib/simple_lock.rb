require "simple_lock/version"
require 'securerandom'

module SimpleLock
  class Configuration
    attr_accessor :race_condition_detection_time
    attr_accessor :adapter

    def initializer
      # There is an assumption that this value is greater than Adapter's read/write latency.
      @race_condition_detection_time = 0.01
      @adapter                       = Rails.cache if defined? Rails
    end
  end

  ADAPTER_METHODS = %w(read write delete).freeze

  class << self
    attr_reader   :config

    def configure
      @config ||= Configuration.new
      yield config
      validate_adapter_compatibility
    end

    def aquire(name, expires_in: nil, &block)
      return if aquired?(name)
      lock_uuid = set_lock(name, expires_in: expires_in)
      return if race_condition_detected?(name, current_lock_uuid: lock_uuid)
      yield
    ensure
      delete_lock(name)
    end

    def aquired?(name)
      !!adapter.read(name)
    end

    private

    def adapter
      config.adapter
    end

    def set_lock(name, expires_in: nil)
      SecureRandom.uuid.tap do |uuid|
        adapter.write(name, uuid, expires_in: expires_in)
      end
    end

    def race_condition_detected?(name, current_lock_uuid:)
      wait_for_competitors_to_finish_writes
      adapter.read(name) != current_lock_uuid
    end

    def wait_for_competitors_to_finish_writes
      config.race_condition_detection_time
    end

    def delete_lock(name)
      adapter.delete(name)
    end

    def validate_adapter_compatibility
      ADAPTER_METHODS.each do |method|
        raise "Adapter is expected to respond to #{ADAPTER_METHODS.join(',')} methods. "\
              "But it does not respond to '#{method}'." unless adapter.respond_to? method
      end
    end
  end
end
