class LastfmScrobble < ActiveRecord::Base
  before_save :update_date

  private

  def update_date
    self.date = Time.at(timestamp).to_date
  end
end
