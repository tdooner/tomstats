class PhoneUsageHistory < ActiveRecord::Base
  scope :last_365_days, -> { where('date > ?', Date.today - 365) }
  scope :in_app, -> { where('name != ?', 'Screen locked') }
end
