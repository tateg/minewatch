#!/usr/bin/env ruby

require 'dotenv'

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

mailer.deliver
