require 'spec_helper'

describe Redmemo do

  it "has a version number" do
    expect(Redmemo::VERSION).not_to be nil
  end


  describe "#cache_method" do
    class Horse
      include Redmemo::Cache

      cache_method :compute_hp
      cache_method :compute_mileage
      cache_method :compute_speed, cache_key: :odd_cache_key
      attr_reader :id

      def initialize(id)
        @id = id
        @compute_hp = 0
        @compute_mileage = 0
        @speed = 0
      end

      def compute_hp
        #intensive stuff
        @compute_hp += 1
        @id + @compute_hp
      end

      def compute_mileage
        @compute_mileage += 100
        @id + @compute_mileage
      end

      def compute_speed
        @speed += 10
        @id + @speed
      end

      def cache_key
        @id
      end

      def odd_cache_key
        @id % 2
      end

    end

    before do
      $redis.flushdb
    end

    it "calls the cached method just once" do
      h = Horse.new(10)
      h.compute_hp
      10.times{h.compute_hp}

      expect(h.instance_variable_get("@compute_hp")).to eq(1)
    end

    it "returns the cached value" do
      h = Horse.new(20)
      10.times{h.compute_hp}
      val = h.compute_hp

      expect(val).to eq(21)
    end

    it "caches data based on cache key" do
      h = Horse.new(30)
      10.times{h.compute_hp}

      expect(h.compute_hp).to eq(31)

      b = Horse.new(33)
      10.times{b.compute_hp}

      expect(b.compute_hp).to eq(34)
    end

    it "caches data based on method" do
      h = Horse.new(30)
      10.times do
        h.compute_hp
        h.compute_mileage
      end

      expect(h.compute_hp).to eq(31)
      expect(h.compute_mileage).to eq(130)
    end

    class Mule
      include Redmemo::Cache

      def compute_hp
        "awesome"
      end

      def cache_key
        1
      end
      cache_method :compute_hp
    end

    it "caches data based on class name" do
      h = Horse.new(30)
      b = Mule.new
      10.times do
        h.compute_hp
        b.compute_hp
      end

      expect(h.compute_hp).to eq(31)
      expect(b.compute_hp).to eq("awesome")
    end

    it "caches data based on the cache_key" do
      a = Horse.new(30)
      b = Horse.new(32)
      c = Horse.new(34)

      a.compute_speed #this is the only time it computes
      b.compute_speed
      c.compute_speed

      expect(a.compute_speed).to eq(40)
      expect(b.compute_speed).to eq(40)
      expect(c.compute_speed).to eq(40)

      d = Horse.new(35)
      expect(d.compute_speed).to eq(45)
    end
  end

  describe "#cache_methods" do
    class Cheetah
      include Redmemo::Cache
      cache_methods :speed, :mileage

      def speed
        get_new_rand + 1
      end

      def mileage
        get_new_rand + 2
      end

      def get_new_rand
        @last_rand = Random.rand
      end

      def cache_key
        self.object_id
      end
    end

    it "caches multiple methods" do
      a = Cheetah.new
      first_speed = a.speed
      expect(a.speed).to eq(first_speed)

      first_mileage = a.mileage
      expect(a.mileage).to eq(first_mileage)
    end

    class Panther
      include Redmemo::Cache
      cache_methods :speed, :mileage, cache_key: :id

      attr_accessor :id
      def initialize(id)
        @id = id
      end

      def speed
        get_new_rand + 1
      end

      def mileage
        get_new_rand + 2
      end

      def get_new_rand
        @last_rand = Random.rand
      end

    end


    it "caches multiple methods with a cache_key" do
      a = Panther.new(33)
      first_speed = a.speed
      expect(a.speed).to eq(first_speed)

      a.id = 44
      expect(a.speed).not_to eq(first_speed)
    end
  end
end
