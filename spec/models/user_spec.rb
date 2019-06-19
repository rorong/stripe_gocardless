require 'rails_helper'

RSpec.describe User, type: :model do

  context "create stripe customer from token" do
    it "create new stripe customer from stripe token" do
      @user1 = create(:user)
      @user1.setup_stripe_card_details(@stripe_test_helper.generate_card_token)
      expect(@user1.stripe_customer_id).to_not be_nil
    end
  end
end
