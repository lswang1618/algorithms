ActionMailer::Base.smtp_settings = {
  :user_name            => 'hellotoken',
  :password             => 'this1isournewemailvendor',
  :domain               => 'hellotoken.com',
  :address              => 'smtp.sendgrid.net',
  :port                 => 587,
  :authentication       => :plain,
  :enable_starttls_auto => true
}
