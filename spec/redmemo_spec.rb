require 'spec_helper'

describe Redmemo do

  class TestHarnessHorse
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

  it "has a version number" do
    expect(Redmemo::VERSION).not_to be nil
  end

  it "calls the cached method just once" do
    h = TestHarnessHorse.new(10)
    h.compute_hp
    10.times{h.compute_hp}

    expect(h.instance_variable_get("@compute_hp")).to eq(1)
  end

  it "returns the cached value" do
    h = TestHarnessHorse.new(20)
    10.times{h.compute_hp}
    val = h.compute_hp

    expect(val).to eq(21)
  end

  it "caches data based on cache key" do
    h = TestHarnessHorse.new(30)
    10.times{h.compute_hp}

    expect(h.compute_hp).to eq(31)

    b = TestHarnessHorse.new(33)
    10.times{b.compute_hp}

    expect(b.compute_hp).to eq(34)
  end

  it "caches data based on method" do
    h = TestHarnessHorse.new(30)
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
    h = TestHarnessHorse.new(30)
    b = Mule.new
    10.times do
      h.compute_hp
      b.compute_hp
    end

    expect(h.compute_hp).to eq(31)
    expect(b.compute_hp).to eq("awesome")
  end

  it "caches data based on the cache_key" do
    a = TestHarnessHorse.new(30)
    b = TestHarnessHorse.new(32)
    c = TestHarnessHorse.new(34)

    a.compute_speed #this is the only time it computes
    b.compute_speed
    c.compute_speed

    expect(a.compute_speed).to eq(40)
    expect(b.compute_speed).to eq(40)
    expect(c.compute_speed).to eq(40)

    d = TestHarnessHorse.new(35)
    expect(d.compute_speed).to eq(45)
  end
end
