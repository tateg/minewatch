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
# Instantiate mailer
mailer = Mailer.notification(to: ENV['EMAIL_TO'], from: ENV['EMAIL_FROM'], subject: ENV['EMAIL_SUBJECT'])
# Instantiate scheduler
scheduler = Rufus::Scheduler.new
# Instantiate MineWatch
minewatch = MineWatch.new({ pool_api_url: ENV['ETH_POOL_API_URL'],
                            addr: ENV['ETH_ADDR'],
                            workers: ENV['WORKERS']
})

scheduler.every '5m' do
  mailer.deliver unless minewatch.all_workers_online?
end

scheduler.cron '0 18 * * *' do
  # deliver daily summary here
end

scheduler.join
