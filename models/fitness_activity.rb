require 'rexml/document'

class FitnessActivity < ActiveRecord::Base
  has_many :tag_processing_records, as: :source

  def date
    doc = REXML::Document.new(data, ignore_whitespace_nodes: :all)
    Date.parse(REXML::XPath.match(doc, '//Activity/Id')[0].text)
  end
end
