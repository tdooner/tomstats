require 'net/http'
require 'json'

class DropboxClient
  def initialize(token = ENV['DROPBOX_ACCESS_TOKEN'])
    @token = token
  end

  def list_directory(directory)
    unless @token && @token.length > 0
      raise 'Unconfigured DROPBOX_ACCESS_TOKEN!'
    end

    list_url = URI('https://api.dropboxapi.com/2/files/list_folder')

    Net::HTTP.start(list_url.host, list_url.port, use_ssl: true) do |http|
      req = Net::HTTP::Post.new(list_url.request_uri)
      req['Authorization'] = "Bearer #{ENV['DROPBOX_ACCESS_TOKEN']}"
      req['Content-Type'] = 'application/json'
      req.body = JSON.generate(
        path: directory,
      )
      resp = http.request(req)

      unless resp.code.to_i < 300
        raise "Bad response from Dropbox: #{resp.code} #{resp.body}"
      end

      entries = JSON.parse(resp.body)['entries']
      entries.map do |entry|
        DropboxFile.new(*entry.values_at(*DropboxFile.members.map(&:to_s)))
      end
    end
  end

  # unused: .tag, server_modified
  DropboxFile = Struct.new(:name, :path_lower, :path_display, :id, :client_modified, :rev, :size)
end
