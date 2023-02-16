class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  PLAN_AMOUNT = '100'.freeze
  CURRENCY = 'usd'.freeze
  DESCRIPTION = 'Software development services'.freeze
  SHIPPING = {
    name: 'Jenny Rosen'.freeze,
    address: {
              line1: '510 Townsend St'.freeze,
              postal_code: '98140'.freeze,
              city: 'San Francisco'.freeze,
              state: 'CA'.freeze,
              country: 'US'.freeze,
            }}
  PAYMENT_METHOD = 'pm_card_visa'.freeze
  INTERVAL_UNIT = 'monthly'.freeze
  GO_CARDLESS_NAME = 'Test Monthly Plan'.freeze
  GO_CARDLESS_CURRENCY = 'GBP'.freeze

  def setup_stripe_card_details(stripe_token)
    if stripe_customer_id.blank?
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
