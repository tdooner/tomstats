require 'rexml/document'

class FitnessActivity < ActiveRecord::Base
  has_many :tag_processing_records, as: :source

  scope :last_365_days, -> { where('date > ?', Date.today - 365) }

  before_save :update_date

  private

  def update_date
    doc = REXML::Document.new(data, ignore_whitespace_nodes: :all)
    id = REXML::XPath.match(doc, '//Activity/Id')[0]

    return unless id

    self.date = Date.parse(id.text)
  end
end
