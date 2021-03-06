require 'webpush'

class MessageSender
  def self.send_test_notification
    self.send("This is a test notification at #{Time.now}")
  end

  def self.send_daily_update
    last_spreadsheet = DailySpreadsheetEntry.order(:date).last.date

    self.send("Last daily spreadsheet: #{last_spreadsheet}")
  end

  private

  def self.send(message)
    PushNotificationSubscriber.find_each do |subscription|
      begin
        Webpush.payload_send(
          endpoint: subscription.endpoint,
          # TODO: convert message to JSON to allow for custom
          # header/icon/actions
          message: message,
          p256dh: subscription.p256dh,
          auth: subscription.auth,
          vapid: {
            subject: 'mailto:tomdooner@gmail.com',
            public_key: ENV['VAPID_PUBLIC_KEY'],
            private_key: ENV['VAPID_PRIVATE_KEY'],
          }
        )
      rescue Webpush::InvalidSubscription
        $stderr.puts 'Webhook subscription expired, deleting.'
        subscription.delete
      end
    end
  end
end
