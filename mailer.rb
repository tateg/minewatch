require 'action_mailer'

# compose and send email notifications
class Mailer < ActionMailer::Base
  def notification(to:, from:, subject:, view_args:)
    @worker_diff = view_args[:worker_diff] || 'N/A'
    @footer_timestamp = footstamp

    mail_with_format(to: to, from: from, subject: subject)
  end

  def daily_summary(to:, from:, subject:, view_args:)
    @worker_diff = view_args[:worker_diff] || 'N/A'
    @current_hashrate = view_args[:current_hashrate] || 'N/A'
    @avg_hashrate = view_args[:avg_hashrate] || 'N/A'
    @usd_per_day = view_args[:usd_per_day] || 'N/A'
    @usd_per_month = view_args[:usd_per_month] || 'N/A'
    @footer_timestamp = footstamp

    mail_with_format(to: to, from: from, subject: subject)
  end

  private

  def footstamp
    Time.now.strftime('%m/%d/%Y%l:%M:%S %p %Z') # timestamp for footer of email to prevent trimming
  end

  def mail_with_format(to:, from:, subject:)
    mail(to: to, from: from, subject: subject) do |format|
      format.text
      format.html
    end
  end
end
