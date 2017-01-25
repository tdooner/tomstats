class LastfmScrobble < ActiveRecord::Base
  scope :last_365_days, -> { where('date > ?', Date.today - 365) }

  before_save :update_date

  private

  def update_date
    self.date = Time.at(timestamp).to_date
  end
end
