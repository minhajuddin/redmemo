require 'spec_helper'

describe Redmemo do

  class TestHarnessHorse
    include Redmemo::Cache

    cache_method :compute_hp
    attr_reader :id

    def initialize(id)
      @id = id
      @compute_hp = 0
    end

    def compute_hp
      #intensive stuff
      @compute_hp += 1
      @id + @compute_hp
    end

    def cache_key
      @id
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

end
