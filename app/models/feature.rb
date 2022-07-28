class Feature < ApplicationRecord
  belongs_to :plan
  #validations
  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: {maximum: 20}
  validates :code, presence: true, uniqueness: { case_sensitive: false }, length: {maximum: 20}
  validates :unit_price, presence: true, length: {maximum: 10}
  validates :max_unit_limit, presence: true,length: {maximum: 20}






end
