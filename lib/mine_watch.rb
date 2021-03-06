require 'net/http'
require 'json'

# wrapper for querying pool, miner and worker status via pool api
class MineWatch
  attr_reader :pool_api_url, :addr, :root_query, :workers

  def initialize(args)
    @pool_api_url = args.fetch(:pool_api_url)
    @addr         = args.fetch(:addr)
    @workers      = args.fetch(:workers)
  end

  def pool_stats
    make_query(pool_stats_query)['data']['poolStats']
  end

  def pool_workers
    pool_stats['workers']
  end

  def current_active_workers
    make_query(miner_stats_query)['data']['activeWorkers'].to_i
  end

  def all_workers_online?
    workers == current_active_workers
  end

  def worker_info
    make_query(miner_stats_query)['data']
  end

  def usd_per_min
    worker_info['usdPerMin'].to_f
  end

  def usd_per_day
    (usd_per_min * 60 * 24).round(2)
  end

  def usd_per_month
    (usd_per_day * 30).round(2)
  end

  # current in MH/s
  def current_hashrate
    worker_info['currentHashrate'].to_i / 1_000_000
  end

  # avg in MH/s
  def avg_hashrate
    worker_info['averageHashrate'].to_i / 1_000_000
  end

  private

  def miner_query
    "/miner/#{addr}/"
  end

  def miner_stats_query
    miner_query + 'currentStats'
  end

  def miner_worker_query
    miner_query + 'workers'
  end

  def pool_stats_query
    '/poolStats'
  end

  def make_query(type)
    u_path = URI(pool_api_url + type)
    res = Net::HTTP.get(u_path)
    JSON.parse(res)
  end
end
