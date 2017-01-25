require_relative './environment.rb'

require 'sinatra'
require 'sinatra/reloader' if development?

ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])

set :public_folder, 'build/'

get '/' do
  <<-HTML
  <html>
    <body>
      <div id='app'></div>
      <script type='text/javascript' src='js/DateHistogram.bundle.js'></script>
    </body>
  </html>
  HTML
end
