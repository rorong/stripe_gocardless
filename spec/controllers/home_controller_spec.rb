require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  login_user

  context "create gocardless subscription" do
    it "should have a current_user" do
      expect(subject.current_user).to_not eq(nil)
    end

    it "create new stripe customer from stripe token" do
      post :create_subscription, params: { stripeToken: @stripe_test_helper.generate_card_token }
      expect(subject.current_user.stripe_customer_id).to_not be_nil
    end

    it "should redirect to gocardless payment page" do
      post :create_subscription, params: { stripeToken: @stripe_test_helper.generate_card_token }
      expect(response.location).to match('https://pay-sandbox.gocardless.com')
    end
  end

end
