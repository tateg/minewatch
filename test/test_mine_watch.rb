require 'test_helper'
require_relative '../lib/mine_watch.rb'

class TestMineWatch < Minitest::Test
  def setup
    @test_url = ENV['TEST_POOL_API_URL']
    @test_addr = ENV['TEST_ADDR']
    @test_workers = ENV['TEST_WORKERS']
    @minewatch = MineWatch.new(pool_api_url: @test_url, addr: @test_addr, workers: @test_workers)
  end

  def test_class_can_be_instantiated
    assert_kind_of(MineWatch, @minewatch, 'Error, class did not instantiate')
  end

  def test_api_more_than_one_pool_worker_online
    VCR.use_cassette(__method__) do
      pool_workers = @minewatch.pool_workers
      assert_operator(pool_workers, :>, 1, "Error, active pool workers #{pool_workers} not greater than 1")
    end
  end

  def test_api_can_get_miner_workers
    VCR.use_cassette(__method__) do
      miner_workers = @minewatch.current_active_workers
      assert_operator(miner_workers, :>=, 1, "Error, miner workers #{miner_workers} not greater than or equal to 1")
    end
  end

  def test_api_can_get_usd_per_min
    VCR.use_cassette(__method__) do
      usd_per_min = @minewatch.usd_per_min
      assert_operator(usd_per_min, :>, 0.0, "Error, usd_per_min #{usd_per_min} not greater than 0.0")
    end
  end
end
