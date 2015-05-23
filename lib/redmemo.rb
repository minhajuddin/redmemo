require "redmemo/version"

require 'redis'
require 'base64'
$redis = Redis.new

module Redmemo
  module Cache

    def self.included(base)
      base.include(InstanceMethods)
      base.extend(ClassMethods)
      # creates a custom cache module for the base class
      # this module will hold the overriding methods
      base.prepend(const_set("#{base.name}Cache", Module.new))
    end

    # start of instance methods
    module InstanceMethods
      def encode_for_cache(val)
        Base64.encode64(Marshal.dump(val))
      end

      def decode_for_cache(encoded_val)
        Marshal.load(Base64.decode64(encoded_val))
      end

      def cached_value_for(key, lazy_val)
        cached_val = $redis.get(key)
        return decode_for_cache(cached_val) if cached_val

        # cache miss: first execution
        lazy_val.().tap do |val|
          $redis.set(key, encode_for_cache(val))
        end
      end
    end
    # end of instance methods

    # start of class methods
    module ClassMethods
      DEFAULT_OPTIONS = {cache_key: :cache_key}
      # usage:
      # cache_method :m1, :cache_key => :your_custom_cache_key
      # :cache_key is set to :cache_key by default, this is the activerecord cache key method
      def cache_method(method_name, options = {})
        options = DEFAULT_OPTIONS.merge(options || {})
        cache_module = const_get("#{self.name}Cache")
        cache_key_method = options[:cache_key] || options["cache_key"]
        cache_module.class_eval do
          define_method(method_name) do
            key = "#{self.class.name}/#{method_name}/#{self.send(cache_key_method)}"
            cached_value_for(key, ->{super()})
          end
        end
      end


      # usage:
      # cache_methods :m1, :m2, :m3, :cache_key => :your_custom_cache_key
      # :cache_key is set to :cache_key by default, this is the activerecord cache key method
      def cache_methods(*args)
        options = args.pop if args.last.is_a?(Hash)
        methods = args

        methods.each do |method|
          self.cache_method(method, options)
        end
      end
    end
    # end of class methods

  end
end
