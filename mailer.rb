#!/usr/bin/env ruby

require 'action_mailer'

class Mailer < ActionMailer::Base
  def notification(to:, from:, subject:, worker_diff:)
    @worker_diff = worker_diff
    @footer_timestamp = Time.now.strftime("%m/%d/%Y%l:%M%p %Z") # timestamp bottom of email to prevent trimming
    mail(to: to, from: from, subject: subject) do |format|
      format.text
      format.html
    end
  end
end
