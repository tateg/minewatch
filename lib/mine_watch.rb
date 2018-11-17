require 'net/http'
require 'json'

class MineWatch
  attr_reader :pool_api_url, :addr, :root_query, :workers

  def initialize(args)
    @pool_api_url = args.fetch(:pool_api_url)
    @addr         = args.fetch(:addr)
    @workers      = args.fetch(:workers)
  end

  def current_active_workers
    make_query(miner_stats_query)['data']['activeWorkers'].to_i
  end

  def all_workers_online?
    workers == current_active_workers
  end

  def get_worker_info
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

  def make_query(type)
    u_path = URI(pool_api_url + type)
    res = Net::HTTP.get(u_path)
    JSON.parse(res)
  end
end
