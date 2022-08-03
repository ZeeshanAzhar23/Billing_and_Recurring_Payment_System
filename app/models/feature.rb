# frozen_string_literal: true
class Feature < ApplicationRecord
  belongs_to :plan
  has_one :feature_usage, dependent: :destroy
  # validations
  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 20 }
  validates :code, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 20 } ,
                                                               numericality: {only_integer: true}
  validates :unit_price, presence: true, length: { maximum: 10 }, numericality: true
  validates :max_unit_limit, presence: true, length: { maximum: 20 }, numericality: true
end
