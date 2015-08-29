class Payout < ActiveRecord::Base
  include Utilities

  belongs_to :publisher
  after_create :update_alpha_id

  def get_status_message
    msg = ""
    if self.status == "SUCCESS"
      msg = "Paid out successfully to your PayPal account!"
  	elsif self.status == "UNCLAIMED"
      msg = "Your payout was recorded, but you haven't confirmed the payment.\n"
      msg += "Please log in or sign up on PayPal with the same email as this account, and your payment will be waiting for you.\n"
      msg += "If you do not claim your payout in 30 days, it will be reversed and the money will be returned to your hellotoken account.\n"
      msg += "Please contact support@hellotoken.com if you have fruther questions."
    else
      msg = "Your payout was recorded, but came back with a status of #{self.status}.\n"
      msg += "Please contact support@hellotoken.com for further support."
    end
    return msg
  end

  private
    def update_alpha_id
      self.update(alpha_id: generate_alpha_id(self.class))
    end

end

