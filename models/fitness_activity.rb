class FitnessActivity < ActiveRecord::Base
  has_many :tag_processing_records, as: :source
end
