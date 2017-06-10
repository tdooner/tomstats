class DailySpreadsheetEntry < ActiveRecord::Base
  LEGACY_ENTRY_TYPES = {
    'How was today? [Good]' => :how_good,
    'How was today? [Unique]' =>  :how_unique,
    'How was today? [Productive]' =>  :how_productive,
    'Who did you hang out with?' =>  :hung_out_with,
    'How many glasses of alcohol today?' =>  :glasses_alcohol,
  }

  scope :last_365_days, -> { where('date > ?', Date.today - 365) }

  def self.create_from_row(row)
    date = if row['Timestamp'].include?(' ')
             DateTime.strptime(row['Timestamp'], '%m/%d/%Y %T')
           else
             DateTime.strptime(row['Timestamp'], '%m/%d/%Y')
           end

    if date.hour <= 12
      date = date - 1
    end

    row.each do |col, type|
      next if col == 'Timestamp'

      entry_name = LEGACY_ENTRY_TYPES.fetch(col) do |entry_type|
        entry_type.downcase.scan(/\w+/).first(5).join('_')
      end

      entry = DailySpreadsheetEntry
        .where(date: date.to_date, entry_type: entry_name)
        .first_or_create
      entry.update_attributes(value: row[col])
    end
  end
end
