# frozen_string_literal: true

# Description/Explanation of User class
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  PLAN_AMOUNT = '100'
  CURRENCY = 'usd'
  DESCRIPTION = 'Software development services'
  SHIPPING = {
    name: 'Jenny Rosen',
    address: {
      line1: '510 Townsend St',
      postal_code: '98140',
      city: 'San Francisco',
      state: 'CA',
      country: 'US'
    }
  }.freeze
  PAYMENT_METHOD = 'pm_card_visa'
  INTERVAL_UNIT = 'monthly'
  GO_CARDLESS_NAME = 'Test Monthly Plan'
  GO_CARDLESS_CURRENCY = 'GBP'

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
