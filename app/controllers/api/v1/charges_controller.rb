require "stripe"

class Api::V1::ChargesController < ActionController::API
  def create
    # pry.byebug
    order = Order.create!(state: "pending", user: current_user)

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
      success_url: "http://localhost:8080/dashboard/onboarding?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: "https://podwii.com",
    )
    order.update(checkout_session_id: session.id)
    render json: { sessionId: session.id }
  rescue Stripe::CardError => e
    render json: { message: e.message }, status: :not_acceptable
  end
end
