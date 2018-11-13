#!/usr/bin/env ruby

require 'action_mailer'

class Mailer < ActionMailer::Base
  def notification(to:, from:, subject:)
    mail(to: to, from: from, subject: subject) do |format|
      format.text
      format.html
    end
  end
end
