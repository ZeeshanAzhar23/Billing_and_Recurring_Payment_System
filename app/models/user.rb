# frozen_string_literal: true
class User < ApplicationRecord
  include ImageUploader::Attachment(:image)

  enum role: { 'buyer' => 0, 'admin' => 1 }
  # validations
  validates :password, confirmation: true
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  # Associations
  has_many :subscriptions, dependent: :destroy
  has_many :plans, through: :subscriptions
  has_many :subscriptions, dependent: :destroy
  def to_s
    email
  end
  # Callback to Create Stripe customer after creating customer in database
  after_create do
    customer = Stripe::Customer.create(email: email, name: name)
    update(customer_id: customer.id)
  end
  # Find if user has any active subscriptions for billing purposes.
  def subscribed?
    subscriptions.where(status: 'active').any?
  end
  after_save do
    image_derivatives! unless image_data.nil?
  end
end
