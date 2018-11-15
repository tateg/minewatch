#!/usr/bin/env ruby

require 'action_mailer'

class Mailer < ActionMailer::Base
  def notification(to:, from:, subject:, worker_diff:)
    @worker_diff = worker_diff
    mail(to: to, from: from, subject: subject) do |format|
      format.text
      format.html
    end
  end
end
