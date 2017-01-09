class LastfmScrobble < ActiveRecord::Base
  def date
    Time.at(timestamp).to_date
  end
end
