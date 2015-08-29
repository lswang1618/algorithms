# model representing publishers i.e. content purchasers
# see foreign relations for schema
# contrast with "Publisher" class

class Researcher < ActiveRecord::Base
  include User # some shared methods
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  before_update { |researcher| # send email hook if going from false --> true
    researcher.send_verification if researcher.verified_changed? and !researcher.verified_was} 

  has_many :publishers, through: :questions
  
  has_many :campaigns
  has_many :questions, through: :campaigns

  validates_acceptance_of :terms_of_service
  validates :name, length: {
     maximum: 30, # Arbitrary
  }
  validates :company_name, length: {
     maximum: 30, # Arbitrary
  }
  validates :website, length: {
     maximum: 30, # Arbitrary
  }

  # # overrides devise method
  # # generate a random id after creation
  def after_confirmation
    a_id = generate_alpha_id(self.class)
    self.update(alpha_id: a_id)
  end

 def self.signup_without_email(email,password)
    p = Researcher.new(email: email, password: password, password_confirmation: password)
    p.skip_confirmation!
    p.save(validate: false)
    p.update_columns(verified: true)
    self.after_confirmation
    return p
  end

  def get_background_color
    if self.use_custom_colors then self.logo_background_hex else '#FFBF3F' end
  end

  def get_text_color
    if self.use_custom_colors then self.logo_text_hex else '#FFFFFF' end
  end

  # handle http:// for absolute paths
  def get_website
    if !self.use_custom_colors or self.website.nil?
      return "http://hellotoken.com" 
    elsif self.website[0..6] == "http://"
      return self.website
    else
      return "http://"+self.website
    end 
  end

  def get_sponsor_text
    if self.use_custom_colors and self.company_name.present?
      return "Powered by #{self.company_name}" 
    else 
      return "Powered by hellotoken" 
    end
  end
  # # send email confirming verificationn with user
  # def send_verification
  #   HellotokenMailer.verification_notification(self).deliver
  # end

  # def verify
  #   if not self.verified?
  #     self.update(verified: true)
  #   end
  # end
end