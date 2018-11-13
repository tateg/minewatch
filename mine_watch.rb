#!/usr/bin/env ruby

require 'net/http'
require 'json'

WORKERS = ENV['ETH_WORKERS']

# Ethereum
ETH_POOL_API_URL = ENV['ETH_POOL_API_URL']
ETH_ADDR = ENV['ETH_ADDR']
ETH_ROOT_PATH = "/miner/#{ETH_ADDR}/"
ETH_STAT_PATH = ETH_ROOT_PATH + 'currentStats'
ETH_WORK_PATH = ETH_ROOT_PATH + 'workers'

# Z-cash
ZEC_POOL_API_URL = ''
ZEC_ADDR = ''

# Monero
XMR_POOL_API_URL = ''
XMR_ADDR = ''

def make_query(pool:, path:)
  u_path = URI(pool + path)
  res = Net::HTTP.get(u_path)
  JSON.parse(res)
end

def current_active_workers(pool:, path:)
  make_query(pool: pool, path: path)['data']['activeWorkers'].to_i
end

def workers_online?(pool:, path:)
  WORKERS == current_active_workers(pool: pool, path: path)
end

def get_worker_info(pool:, path:)
  
end
