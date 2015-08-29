class HellotokenMailer < Devise::Mailer   

  helper :application # gives access to all helpers defined within `application_helper`.
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`

  default template_path: 'devise/mailer' # to make sure that your mailer uses the devise views
  default from: "contact@hellotoken.com"
  default content_type: "text/html"

  # email sent after publisher/researcher is verified in our DB
  def verification_notification(resource)
    @resource = resource
    mail(to: resource.email, subject: "Your Account Has Been Verified")
  end

  def confirmation_instructions(record, token, options={})
    # Use different e-mail templates for signup e-mail confirmation and for when a user changes e-mail address.
    if record.pending_reconfirmation?
      options[:template_name] = 'reconfirmation_instructions'
    else
      options[:template_name] = 'confirmation_instructions'
    end

    super
  end

  def test(resource)
    @resource = resource
    mail(to: resource.email, subject: "This is the subject")
  end

end