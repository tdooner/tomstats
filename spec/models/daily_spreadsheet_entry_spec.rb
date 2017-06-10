require 'spec_helper'

RSpec.describe DailySpreadsheetEntry do
  # populate this with the Vim command:
  # :r !curl $DAILY_TRACKING_URL -sq 2>/dev/null | head -n1 | tr "\t" "\n" | awk '{ print "\""$0"\"," }'
  let(:headers) do
    [
      'Timestamp',
      'How was today? [Good]',
      'How was today? [Unique]',
      'How was today? [Productive]',
      'Who did you hang out with?',
      'How many glasses of alcohol today?',
      'Notable Events?',
      'Mg of caffeine',
      'About how much money did you spend today?',
    ]
  end

  let(:row) do
    "6/10/2017 10:07:54\t4\t3\t3\tCfA people\t2\twork and stuff\t300\t70"
  end

  subject do
    DailySpreadsheetEntry.create_from_row(
      CSV.parse(row, headers: headers, col_sep: "\t").first
    )
  end

  it 'creates a row' do
    expect { subject }
      .to change { DailySpreadsheetEntry.count }
      .by(headers.length - 1)

    expect(DailySpreadsheetEntry.find_by(
      date: Date.parse('2017-06-09'),
      entry_type: 'about_how_much_money_did'
    ).value).to eq('70')
  end
end
