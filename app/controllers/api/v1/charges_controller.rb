require "stripe"

class Api::V1::ChargesController < ActionController::API
  def create
    Stripe.api_key = "sk_test_WufmgV5wuW7Rxm7mG8bzSQ3600BtXV2VQL"

    payment_intent = Stripe::PaymentIntent.create(
      amount: 6500,
      currency: "usd",
    )
    # {
    #   clientSecret: payment_intent["client_secret"],
    # }.to_json
    render json: { clientSecret: payment_intent["client_secret"] }
  rescue Stripe::CardError => e
    render json: { message: e.message }, status: :not_acceptable
  end
end
