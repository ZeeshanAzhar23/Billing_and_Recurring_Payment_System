class User < ApplicationRecord
  include ImageUploader::Attachment(:image)
  enum role: %w{buyer admin}
  validates_confirmation_of :password
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :subscriptions, dependent: :destroy
  has_many :plans, through: :subscriptions
  has_many :subscriptions, dependent: :destroy
  after_create do
    customer=Stripe::Customer.create(email: email,name:name)
    update(customer_id: customer.id)
  end
  after_commit :img_derivatives, only: :update
  def subscribed?
    subscriptions.where(status: 'active').any?
  end
  def img_derivatives
    image_derivatives!
  end
end
