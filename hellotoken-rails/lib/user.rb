module User
  include Utilities

  # send email confirming verificationn with user
  def send_verification
    HellotokenMailer.verification_notification(self).deliver
  end

  def verify
    if not self.verified?
      self.update(verified: true)
    end
  end
end