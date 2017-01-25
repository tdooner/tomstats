require_relative './environment.rb'

require 'sinatra'
require 'sinatra/reloader' if development?

ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])

get '/health' do
  [
    DailySpreadsheetEntry,
    FitnessActivity,
    GarminDump,
    LastfmScrobble,
  ].map do |model|
    [model.name, model.last.date]
  end.to_json
end
