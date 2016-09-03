require 'json'
require 'sinatra'
require 'net/http'
require 'uri'

require_relative 'lib/dropbox_client.rb'

$dropbox = DropboxClient.new(ENV['DROPBOX_ACCESS_TOKEN'])

get '/files' do
  $dropbox.list_directory('/Apps/tapiriik').map(&:inspect)
end
