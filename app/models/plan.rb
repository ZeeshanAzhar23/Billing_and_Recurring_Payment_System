class Plan < ApplicationRecord
  has_many :features, dependent: :destroy
  has_many :users, through: :subscriptions
  has_many :subscriptions, dependent: :nullify
  #validations
  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: {maximum: 50}
  validates :monthly_fee, presence: true, length: {maximum: 20}
  validates_numericality_of :monthly_fee, less_than_or_equal_to: BigDecimal(10**8)
  #@price
  attr_reader :price
  after_create do
    @plan=Stripe::Product.create({name: name,})
    update(stripe_plan_id: @plan.id)
    @price=Stripe::Price.create({
      product: @plan.id,
      unit_amount: monthly_fee.to_i,
      currency:'usd',
      recurring: {interval: 'month'},
      metadata: {order_id: '6735'},
    })
    update(price_id: @price.id)
  end

  # def return_price_id
  #   puts 'chcking'
  #   @price.id
  #   puts @price.id
  # end

end
