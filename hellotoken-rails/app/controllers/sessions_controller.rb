class SessionsController < Devise::SessionsController
  prepend_before_action :prevent_double_sign_in, only: [:new, :create]

  def after_sign_in_path_for(resource)
    if publisher_signed_in?
      # should put all of this in a publisher method--but lazy
      incomplete_payouts = current_publisher.incomplete_payouts
      logger.debug "#{incomplete_payouts}"
      Rails.logger.level = 3 # ignore all the annoying request logs
      incomplete_payouts.each do |payout|
        status = PayPal::SDK::REST::PayoutItem.get(payout.paypal_item_id).transaction_status
        if status != payout.status
          payout.status = status
          payout.save
          if status.casecmp("RETURNED") == 0
            current_publisher.refund_payout(payout)
          end
        end
      end
      Rails.logger.level = 0
    end
    '/dashboard'
  end

  private

    # anyone signed in?
    def user_signed_in?
      return (researcher_signed_in? or publisher_signed_in?)
    end 

    def prevent_double_sign_in
      if user_signed_in?
        flash[:error] = "You are already signed in on another account. Please log out before doing that."
        redirect_to root_path and return
      end
    end
end