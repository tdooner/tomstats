class PhoneUsageHistory < ActiveRecord::Base
  scope :last_365_days, -> { where('date > ?', Date.today - 365) }
end
