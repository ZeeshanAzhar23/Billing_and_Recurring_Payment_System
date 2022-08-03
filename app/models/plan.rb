# frozen_string_literal: true
class Plan < ApplicationRecord
  include PlanConcern
  #associations
  has_many :features, dependent: :destroy
  has_many :users, through: :subscriptions
  has_many :subscriptions, dependent: :nullify
  # validations
  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 50 }
  validates :monthly_fee, presence: true, length: { maximum: 20 }
  validates :monthly_fee, numericality: { less_than_or_equal_to: BigDecimal(10**8) }
  attr_reader :price
  #model callbacks
  after_create do
    @plan = Stripe::Product.create({ name: name })
    @flag = true
    update(stripe_plan_id: @plan.id)
  end
  after_update do
    unless @flag
      Stripe::Product.update(
        stripe_plan_id,
        name: name
      )
    end
  end
end
