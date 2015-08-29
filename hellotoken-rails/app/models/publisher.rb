  # model representing publishers i.e. content distributors
# see foreign relations for schema
# contrast with "Researcher" class

class Publisher < ActiveRecord::Base
  include User
  include PayPal::SDK::OpenIDConnect

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  before_update { |publisher| # send email hook if going from false --> true
    publisher.send_verification if publisher.verified_changed? and !publisher.verified_was} 

  # foreign relations
  has_many :articles, dependent: :destroy
  # has_many :pubquestions
  # has_many :questions, through: :articles
  has_many :responses, through: :articles
  # has_many :questions, through: :pubquestions
  # has_many :responses, through: :questions
  has_many :researchers, through: :questions
  has_many :readers, through: :articles
  belongs_to :category

  has_many :payouts, dependent: :destroy

  has_attached_file :logo, 
    styles: {
      icon: "450x80>!",#450x80>!
      medium: "500x500  "
    },
    convert_options: {
      icon: '-set colorspace sRGB -strip',
      medium: '-set colorspace sRGB -strip'
    },
    default_url: "ht_logo_small.png"    

  validates_attachment :logo, 
    :content_type => { :content_type => /^image\/(jpeg|png|gif|tiff)$/ },
    :size => {:less_than => 4.megabytes}
  validates_acceptance_of :terms_of_service
  validates :name, length: {
     maximum: 40, # Arbitrary
  }
  validates :blog_name, length: {
     maximum: 40, # Arbitrary
  }
  validates :domain, length: {
     maximum: 40, # Arbitrary
  }

  @@minimum_payout = 100
  @@response_value = 0.03
  # # overrides devise method
  # # generate a random id after creation
  def after_confirmation
    a_id = generate_alpha_id(self.class)
    self.update(alpha_id: a_id)
  end

  def self.signup_without_email(email,password)
    p = Publisher.new(email: email, password: password, password_confirmation: password)
    p.skip_confirmation!
    p.save(validate: false)
    p.update_columns(verified: true)
    self.after_confirmation
    return p
  end

  def incomplete_payouts
    return self.payouts.where.not(status: "SUCCESS")
  end

  def minimum_payout
    return @@minimum_payout
  end

  def ready_for_payout?
    return ((self.email == "briantruong@college.harvard.edu") or (self.responses.count * @@response_value - self.paid >= @@minimum_payout))  
  end

  def refund_payout(payout)
    current_paid = self.paid
    self.paid = current_paid - payout.amount
    self.save
  end

  def payout(paypal_auth_code, custom_amount=0)
    Payout.transaction do 
      begin
        # get payout amounts
        former_pay = self.paid
        if custom_amount == 0
          new_pay = self.money_responses.size * @@response_value # should be earnings column
          amount = new_pay - former_pay
        else
          amount = custom_amount
          new_pay = former_pay + amount
        end

        # Get user info from token
        Rails.logger.level = 3 # ignore all the annoying request logs
        paypal_token = Tokeninfo.create(paypal_auth_code)
        Rails.logger.level = 0
        paypal_user_info = paypal_token.userinfo

        # Create payouts
        ht_payout = Payout.create(amount: amount, publisher_id: self.id)
        paypal_payout = PayPal::SDK::REST::Payout.new(
          {
            :sender_batch_header => {
              :sender_batch_id => ht_payout.alpha_id,
              :email_subject => 'Payout from hellotoken',
            },
            :items => [
              {
                :recipient_type => 'EMAIL',
                :amount => {
                  :value => amount,
                  :currency => 'USD'
                },
                :note => 'Thanks for using hellotoken!',
                :receiver => paypal_user_info.email
                # :sender_item_id => p.alpha_id, Apparently this does jack-shit; https://github.com/paypal/PayPal-Ruby-SDK/issues/138
                # how a company the size of Paypal has open problems like this is absurd
              }
            ]
          }
        )
        Rails.logger.level = 3 # ignore all the annoying request logs
        payout_batch = paypal_payout.create(sync_mode=true)
        Rails.logger.level = 0
        paypal_item = payout_batch.items.first
        status = paypal_item.transaction_status
        paypal_id = paypal_item.payout_item_id
        fees = payout_batch.batch_header.fees.value
        logger.info "Created payout with status [#{status}], alpha_id [#{ht_payout.alpha_id}], paypal_id [#{paypal_id}], amount $[#{amount}], and fees $[#{fees}]"
        
        if %w(DECLINED FAILED REFUSED).include? status
          raise "Paypal payment error: #{status}"
        end

        # do payout recording last
        ht_payout.update(paypal_item_id: paypal_id, fees: fees, status: status)
        ht_payout.save
        self.paid = new_pay
        self.save

        return ht_payout
      rescue => err
        logger.error "#{err}"
        raise ActiveRecord::Rollback
      end
    end
    nil
  end

  # the responses that aren't demographically tied
  def money_responses
    if free_demographics
      money_responses = self.responses.joins(:question).where(questions: {demographic: nil, test: false})
    else
      money_responses = self.responses.joins(:question).where(questions: {test: false})
    end
  end

  # determine if a url is a domain that matches the one belonging to publisher
  def is_valid_domain(url)
    www_stripped_url = url 
    if www_stripped_url.count('.') > 1 # checks if www. or m. or whatever. prepended
                                        # breaks badly for suffixes like .co.uk (since number of periods increases)
      www_stripped_url = www_stripped_url[(www_stripped_url.index('.')+1)..-1]
    end
    return www_stripped_url.casecmp(domain) == 0
  end

  # # send email confirming verificationn with user
  # def send_verification
  #   HellotokenMailer.verification_notification(self).deliver
  # end
end
