require "stripe"

class Api::V1::ChargesController < ActionController::API
  def create
    # Stripe.api_key = "sk_test_WufmgV5wuW7Rxm7mG8bzSQ3600BtXV2VQL"

    session = Stripe::Checkout::Session.create(
      payment_method_types: ["card"],
      line_items: [{
        price: "price_1HGmpwCFTLTHD2lH4SoiqDVo",
        quantity: 1,
      }],
      subscription_data: {
        trial_from_plan: true,
      },
      mode: "subscription",
      success_url: "https://paulgaumer.com?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: "https://japanlifestories.com",
    )
    render json: { sessionId: session.id }
  rescue Stripe::CardError => e
    render json: { message: e.message }, status: :not_acceptable
  end
end
