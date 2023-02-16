class HomeController < ApplicationController
  #create a stripe payment with API
  def create_subscription

    begin
      current_user.setup_stripe_card_details(params[:stripeToken])
      payment_create = Stripe::PaymentIntent.create(payment_params)
      payment_confirm = Stripe::PaymentIntent.confirm(
        "#{payment_create.id}",
        {return_url: "#{create_cardless_url}"},
        {payment_method: User::PAYMENT_METHOD}
      )

      redirect_to "#{payment_confirm.next_action.redirect_to_url.url}"

    rescue Exception => e
      flash[:error] = e.message
      redirect_to root_path
    end
  end

  #create a GoCardless subscription for card holder
  def create_cardless
    if current_user.go_cardless_mandate.present? && current_user.go_cardless_customer.present?
        create_gocardless_subscription

        flash[:success] = 'Your payment has been successfully completed and subscription added to existing bank account.'
        redirect_to root_path
    else

      redirect_flow = GO_CARDLESS_CLIENT.redirect_flows.create(
        gocardless_redirect_params
      )
      redirect_to redirect_flow.redirect_url
    end
  end

  #confirming the GoCardless for user
  def confirm_mandate

    begin
      redirect_flow = GO_CARDLESS_CLIENT.redirect_flows.complete(
                        params[:redirect_flow_id],
                        params: { session_token: "#{current_user.id}" }
                      )
      current_user.go_cardless_customer = redirect_flow.links.customer
      current_user.go_cardless_mandate = redirect_flow.links.mandate

      if current_user.save(validate: false)

        create_gocardless_subscription

        flash[:notice] = 'Your payment has been successfully completed and subscription added to your GoCardless bank account.'
      else
        flash[:error] = 'Something went wrong!'
      end

    rescue StandardError => e
      flash[:error] = e
    end

    redirect_to root_path
  end


 private
    # payment's params
    def payment_params
      {
       amount: (User::PLAN_AMOUNT.to_i * 100),
        currency: User::CURRENCY,
        description: User::DESCRIPTION,
        customer: current_user.stripe_customer_id,
        shipping: {
          name: User::SHIPPING[:name],
          address: {
            line1: User::SHIPPING[:address][:line1],
            postal_code: User::SHIPPING[:address][:postal_code],
            city: User::SHIPPING[:address][:city],
            state: User::SHIPPING[:address][:state],
            country: User::SHIPPING[:address][:country],
          },
        },
        payment_method_types: ['card'],
        payment_method_options: {"card":{"request_three_d_secure":"any"}},
        confirm: true
      }
    end

    # redirect params of gocardless
    def gocardless_redirect_params
      {params: {
          description: 'Demo GoCardless',
          session_token: "#{current_user.id}",
          success_redirect_url: "#{root_url}/confirm_mandate",
          prefilled_customer: {
            email: "#{current_user.email}"
          }
        }}
    end

    #create a gocardless subscription
    def create_gocardless_subscription
      GO_CARDLESS_CLIENT.subscriptions.create(
        params: {
          amount: User::PLAN_AMOUNT.to_i,
          currency: User::GO_CARDLESS_CURRENCY,
          name: User::GO_CARDLESS_NAME,
          interval_unit: User::INTERVAL_UNIT,
          interval: 1,
          start_date: Date.current + 2.month,
          day_of_month: 1,
          links: {
            mandate: current_user.go_cardless_mandate
          }
        }
      )
    end
end
