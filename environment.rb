require 'active_record'
require 'date'
require 'dotenv'
require 'sentry-raven'

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

if ENV['SENTRY_DSN']
  Raven.configure do |config|
    config.dsn = ENV['SENTRY_DSN']
  end
end

require_relative './lib/dropbox_client.rb'
require_relative './lib/garmin_scraper.rb'
require_relative './lib/lastfm_scraper.rb'
require_relative './models/daily_spreadsheet_entry.rb'
require_relative './models/fitness_activity.rb'
require_relative './models/garmin_dump.rb'
require_relative './models/lastfm_scrobble.rb'
require_relative './models/tag_processing_record.rb'

autoload :TagProcessor, 'tag_processor.rb'
autoload :Builder, 'builder.rb'
autoload :PushNotificationSubscriber, './models/push_notification_subscriber.rb'
autoload :MessageSender, 'message_sender.rb'

Dotenv.load(".env.#{ENV['RAILS_ENV']}", '.env')
