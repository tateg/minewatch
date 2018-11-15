#!/usr/bin/env ruby

require 'dotenv'
require 'rufus-scheduler'

# ENV vars are loaded from config.env
Dotenv.load('config.env')

require_relative 'mine_watch'
require_relative 'mailer'

# Initialize ActionMailer Configuration
ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
   :address        => "smtp.gmail.com",
   :port           => 587,
   :domain         => "example.com",
   :authentication => :plain,
   :user_name      => ENV['EMAIL_USERNAME'],
   :password       => ENV['EMAIL_PASSWORD'],
   :enable_starttls_auto => true
  }
# Load mailer views from ./mailer/ dir
ActionMailer::Base.view_paths = File.dirname(__FILE__)
# Instantiate scheduler
scheduler = Rufus::Scheduler.new
# Instantiate MineWatch
minewatch = MineWatch.new({ pool_api_url: ENV['ETH_POOL_API_URL'],
                            addr: ENV['ETH_ADDR'],
                            workers: ENV['WORKERS']
})

worker_alert_count = 0

scheduler.every '5m' do
  workers_online = minewatch.all_workers_online?
  worker_diff = "#{minewatch.current_active_workers}/#{ENV['WORKERS']} Workers Online"
  mailer = Mailer.notification(to: ENV['EMAIL_TO'], from: ENV['EMAIL_FROM'], subject: ENV['EMAIL_SUBJECT'], worker_diff: worker_diff)
  if !workers_online
    worker_alert_count += 1
    mailer.deliver unless (worker_alert_count.between?(3, 72) || (worker_alert_count % 72).zero?)
  else
    worker_alert_count = 0
  end
end

scheduler.cron '0 18 * * *' do
  # deliver daily summary here
end

scheduler.join
