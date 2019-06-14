class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  PLAN_AMOUNT = '100'.freeze

  def setup_stripe_card_details(stripe_token)
    if !stripe_customer_id.present?
      customer = Stripe::Customer.create(
                  email: email,
                  description: "Customer for #{email}",
                  source: stripe_token # obtained with Stripe.js
                )
      self.update_attribute(:stripe_customer_id, customer.id)
    else
      Stripe::Customer.update(stripe_customer_id,
      {
        source: stripe_token
      })
    end
  end
end
