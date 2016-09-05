class LastfmScraper
  API_BASE = URI('https://ws.audioscrobbler.com/2.0/')

  def initialize(apikey)
    raise 'API Key not given' unless apikey
    @apikey = apikey
  end

  def each_scrobble(to: nil, from: nil, &block)
    return to_enum(:each_scrobble) unless block_given?
    page = 1
    keep_fetching = true

    Net::HTTP.start(API_BASE.host, API_BASE.port, use_ssl: true) do |http|
      while keep_fetching
        params = {
          method: 'user.getrecenttracks',
          user: 'tdooner',
          api_key: @apikey,
          format: 'json',
          page: page,
        }
        params[:from] = from if from
        params[:to] = to if to
        puts "Fetching #{page}"

        full_uri = API_BASE.dup
        full_uri.query = URI.encode_www_form(params)

        req = Net::HTTP::Get.new(full_uri.request_uri)
        resp = http.request req
        unless resp.code.to_i < 300
          raise "Error fetching last.fm scrobbles: #{resp.body}"
        end

        parsed = JSON.parse(resp.body)['recenttracks']
        parsed['track'].each do |scrobble|
          return if after && scrobble['date']['uts'].to_i <= after

          block.call(scrobble)
        end
        page += 1
        keep_fetching =
          parsed['@attr']['page'].to_i < parsed['@attr']['totalPages'].to_i
      end
    end
  end
end
