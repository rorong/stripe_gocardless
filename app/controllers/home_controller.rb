class HomeController < ApplicationController
  def create_subscription

    begin
      current_user.setup_stripe_card_details(params[:stripeToken])

      payment_create = Stripe::PaymentIntent.create(
        amount: (User::PLAN_AMOUNT.to_i * 100),
        currency: 'usd',
        description: 'Software development services',
        customer: current_user.stripe_customer_id,
        shipping: {
          name: 'Jenny Rosen',
          address: {
            line1: '510 Townsend St',
            postal_code: '98140',
            city: 'San Francisco',
            state: 'CA',
            country: 'US',
          },
        },
        payment_method_types: ['card'],
        payment_method_options: {"card":{"request_three_d_secure":"any"}},
        confirm: true      )

      payment_confirm = Stripe::PaymentIntent.confirm(
        "#{payment_create.id}",
        {return_url: "#{create_cardless_url}"},
        {payment_method: 'pm_card_visa'}
      )

      redirect_to "#{payment_confirm.next_action.redirect_to_url.url}"

    rescue Exception => e
      flash[:error] = e.message
      return redirect_to root_path
    end
  end

  def create_cardless
    if current_user.go_cardless_mandate.present? && current_user.go_cardless_customer.present?

        create_gocardless_subscription

        flash[:success] = 'Your payment has been successfully completed and subscription added to existing bank account.'
        return redirect_to root_path
    else
      success_redirect_url = "#{root_url}/confirm_mandate"

      redirect_flow = GO_CARDLESS_CLIENT.redirect_flows.create(
        params: {
          description: 'Demo GoCardless',
          session_token: "#{current_user.id}",
          success_redirect_url: success_redirect_url,
          prefilled_customer: {
            email: "#{current_user.email}"
          }
        }
      )
      return redirect_to redirect_flow.redirect_url
    end
  end

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
    def create_gocardless_subscription
      GO_CARDLESS_CLIENT.subscriptions.create(
        params: {
          amount: User::PLAN_AMOUNT.to_i,
          currency: 'GBP',
          name: 'Test Monthly Plan',
          interval_unit: 'monthly',
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
