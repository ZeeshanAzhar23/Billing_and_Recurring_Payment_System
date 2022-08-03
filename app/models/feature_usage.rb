class FeatureUsage < ApplicationRecord
  belongs_to :subscription
  belongs_to :feature
  validates_numericality_of :usage_value
end
