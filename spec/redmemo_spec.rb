require 'spec_helper'

describe Redmemo do

  class TestHarnessHorse
    include Redmemo::Cache

    cache_method :compute_hp

    def initialize
      @compute_hp = 0
    end

    def compute_hp
      #intensive stuff
      @compute_hp += 1
    end

    def cache_key
      1
    end

  end

  it "has a version number" do
    expect(Redmemo::VERSION).not_to be nil
  end

  it "calls the cached method just once" do
    h = TestHarnessHorse.new
    h.compute_hp
    10.times{h.compute_hp}

    expect(h.instance_variable_get("@compute_hp")).to eq(1)
  end

end
