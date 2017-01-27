require_relative './environment.rb'

require 'sinatra'
require 'sinatra/reloader' if development?
require 'webpush'

ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])

set :public_folder, 'build/'

def asset_filename(entry_name)
  JSON.parse(File.read('build/assets.json'))[entry_name]['js']
end

get '/api/date_histogram' do
  headers 'Content-Type' => 'application/json'
  body Builder::DateHistogram.new.tap(&:calculate).to_json
end

post '/send_notification' do
  MessageSender.send_test_notification
end

# TODO: figure out a better way to do this than mirroring the JS in this folder
# as well. (This is necessary for URL-scoped ServiceWorker permissions scheme,
# but should be avoidable if we can serve the JS with a
#   Service-Worker-Allowed: /
# header.
get '/notifications/NotifierServiceWorker.bundle.js' do
  headers 'Content-Type' => 'text/javascript'
  File.read('build/js/' + asset_filename('NotifierServiceWorker'))
end

post '/notifications/register' do
  subscription = JSON.parse(request.body.read)

  PushNotificationSubscriber
    .where(endpoint: subscription['endpoint'])
    .first_or_initialize
    .update_attributes(
      auth: subscription['keys']['auth'],
      p256dh: subscription['keys']['p256dh'],
    )
end

get '/notifications/register' do
  <<-HTML
  <html>
    <head>
      <link rel='manifest' href='/manifest.json' />
    </head>
    <body>
      <div id='app'></div>
      <script type='text/javascript' src='/js/#{asset_filename('Notifier')}'></script>
    </body>
  </html>
  HTML
end

get '/' do
  <<-HTML
  <html>
    <body>
      <div id='app'></div>
      <script type='text/javascript' src='/js/#{asset_filename('DateHistogram')}'></script>
    </body>
  </html>
  HTML
end
