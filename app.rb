require 'sinatra'
require 'net/http'
require 'uri'

get '/files' do
  if !ENV['DROPBOX_ACCESS_TOKEN']
    error 403 do
      'Please configure DROPBOX_ACCESS_TOKEN'
    end
  end

  list_url = URI('https://api.dropboxapi.com/2/files/list_folder')

  Net::HTTP.start(list_url.host, list_url.port) do |http|
    req = Net::HTTP::Get.new(list_url.request_uri)
    req['Authorization'] = "Bearer #{ENV['DROPBOX_ACCESS_TOKEN']}"
    req['Content-Type'] = 'application/json'
    req.body = JSON.generate(
      path: '/Apps/tapiriik',
    )
    resp = http.request(req)
    resp.to_s
  end
end
