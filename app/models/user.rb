class User < ApplicationRecord
  # include HelperMethods
  # has_secure_password
  # # attr_accessor :current_password
  # validate :current_password_is_correct,
  #          if: :validate_password?, on: :update

  enum role: %w{buyer admin}
  #validations
  validates_confirmation_of :password
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :subscriptions, dependent: :destroy
  has_many :plans, through: :subscriptions
  has_many :subscriptions, dependent: :destroy

  has_one_attached :avatar
  # after_commit :add_default_avatar, on: %i[update]

  def avatar_thumbnail
    if avatar.attached?
    avatar.variant(resize: '150x150!').processed
    else
      '/default_profile.jpg'
    end
  end

  # def add_default_avatar
  #   unless avatar.attached?
  #     avatar.attach(
  #       io:File.open(
  #         Rails.root.join(
  #         'app', 'assets', 'images', 'default_profile.jpg'
  #       ), filename: 'default_profile.jpg', content_type: 'image/jpg '
  #     )
  #     )
  #   end
  # end

  def to_s
    email
  end
  after_create do
    customer=Stripe::Customer.create(email: email,name:name)
    update(customer_id: customer.id)
  end
  #Find if user has any active subscriptions for billing purposes.
  def subscribed?
    subscriptions.where(status: 'active').any?
  end


end
