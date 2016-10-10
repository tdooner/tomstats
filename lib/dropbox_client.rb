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
      req['Authorization'] = "Bearer #{@token}"
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
        DropboxFile.new(@token, *entry.values_at(*DropboxFile.members.map(&:to_s)))
      end
    end
  end

  class DropboxFile < Struct.new(:name, :path_lower, :path_display, :id, :client_modified, :rev, :size)
    def initialize(*args)
      @token = args.shift
      super(*args)
    end

    def download
      download_uri = URI('https://content.dropboxapi.com/2/files/download')

      Net::HTTP.start(download_uri.host, download_uri.port, use_ssl: true) do |http|
        req = Net::HTTP::Post.new(download_uri.request_uri)
        req['Authorization'] = "Bearer #{@token}"
        req['Content-Type'] = ''
        req['Dropbox-API-Arg'] = JSON.generate(path: path_lower)

        resp = http.request(req)
        raise "Request Failed: #{download_uri}" unless resp.code.to_i < 300

        return resp.body
      end
    end
  end
end
