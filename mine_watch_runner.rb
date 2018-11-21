#!/usr/bin/env ruby

require 'dotenv'
require 'rufus-scheduler'
require 'logger'
require 'fileutils'

# ENV vars are loaded from config.env
Dotenv.load('config.env')

require_relative 'lib/mine_watch'
require_relative 'mailer'

# Setup logging to log dir and redirect stdout/stderr
log_location = 'log/'
log_name = 'mine_watch_runner.log'
log_rotation_interval = 'daily'
FileUtils.mkdir(log_location) unless Dir.exist?(log_location)
logger = Logger.new(log_location + log_name, log_rotation_interval)

$stdout.reopen(log_location + log_name, 'w')
$stderr.reopen(log_location + log_name, 'w')
puts 'Redirecting STDOUT/STDERR to log'

# Initialize ActionMailer Configuration
logger.info 'Setting up ActionMailer configuration...'
ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  address: 'smtp.gmail.com',
  port: 587,
  domain: 'example.com',
  authentication: :plain,
  user_name: ENV['EMAIL_USERNAME'],
  password: ENV['EMAIL_PASSWORD'],
  enable_starttls_auto: true
}
ActionMailer::Base.view_paths = File.dirname(__FILE__)

logger.info 'Setting up scheduler...'
scheduler = Rufus::Scheduler.new

logger.info 'Setting up new MineWatch instance...'
minewatch = MineWatch.new(pool_api_url: ENV['ETH_POOL_API_URL'],
                          addr: ENV['ETH_ADDR'],
                          workers: ENV['WORKERS'].to_i)
worker_alert_count = 0

# 5 Minute Online Workers Test
scheduler.every '5m' do
  logger.info 'Starting worker alert checks...'
  workers_online = minewatch.all_workers_online?
  worker_diff = "#{minewatch.current_active_workers}/#{ENV['WORKERS']} Workers Online"
  view_args = { worker_diff: worker_diff }
  mailer = Mailer.notification(to: ENV['EMAIL_TO'], from: ENV['EMAIL_FROM'], subject: ENV['EMAIL_SUBJECT_ALERT'], view_args: view_args)
  if !workers_online
    logger.warn "Not all workers are online! (#{worker_diff})"
    if worker_alert_count > 3
      logger.warn "Worker alert count is #{worker_alert_count}, skipping alert"
      mailer.deliver if (worker_alert_count % 12).zero? # only alert every hour after 3 alerts in succession
    else
      logger.info 'Sending alert...'
      mailer.deliver
      worker_alert_count += 1
      logger.info "New worker alert count is #{worker_alert_count}"
    end
  else
    logger.info "All workers online (#{worker_diff}), resetting worker_alert_count and sleeping..."
    worker_alert_count = 0
  end
end

# Daily Summary Email
scheduler.cron '0 18 * * *' do
  logger.info 'Starting daily summary checks...'
  worker_diff = "#{minewatch.current_active_workers}/#{ENV['WORKERS']} Workers Online"
  summary_stats = {
    current_hashrate: minewatch.current_hashrate,
    avg_hashrate: minewatch.avg_hashrate,
    usd_per_day: minewatch.usd_per_day,
    usd_per_month: minewatch.usd_per_month,
    worker_diff: worker_diff
  }
  logger.debug "Building daily summary: #{summary_stats}"
  mailer = Mailer.daily_summary(to: ENV['EMAIL_TO'], from: ENV['EMAIL_FROM'], subject: ENV['EMAIL_SUBJECT_SUMMARY'], view_args: summary_stats)
  logger.info 'Sending daily summary...'
  mailer.deliver
end

scheduler.join
