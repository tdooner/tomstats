class PhoneUsageHistory < ActiveRecord::Base
  include Mixins::AtomicDropboxFile

  scope :last_365_days, -> { where('date > ?', Date.today - 365) }
  scope :in_app, -> { where('name != ?', 'Screen locked') }

  def self.create_from_row(row)
    return nil if row['App name'].length == 0
    return nil if row['App name'].include?(',')
    return nil if row['App name'].include?('Created by App Usage')

    duration = row['Duration'].split(':')

    if duration.length == 2
      hours = 0
      minutes, seconds = duration
    elsif duration.length == 3
      hours, minutes, seconds = duration
    else
      raise "Unknown duration value: #{row['Duration']}"
    end

    where(
      name: row['App name'],
      date: Date.strptime(row['Date'], "%m/%d/%y"),
      time: Time.strptime(row['Time'], "%l:%M:%S %p"),
      duration: "#{hours} hours #{minutes} minutes #{seconds} seconds",
    ).first_or_create
  end
end
