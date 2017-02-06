module Builder
  class PhoneUsage < Base
    def calculate
      times = PhoneUsageHistory.where('name = ?', 'Facebook').order(:date).group(:date).count
      facebook_time =
        PhoneUsageHistory.where('name = ?', 'Facebook').order(:date).group(:date).sum(:duration)
      total_time =
        PhoneUsageHistory.in_app.order(:date).group(:date).sum(:duration)

      @data = {
        times_checked: times.to_a,
        facebook_time_spent: facebook_time.to_a,
        total_time: total_time.to_a,
      }
    end
  end
end
