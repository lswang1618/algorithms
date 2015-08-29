class CampaignsController < ApplicationController
  before_filter :check_researcher # make sure user is a researcher; exile them otherwise
  before_action :check_admin, only: [:show, :index, :update]
  before_action :set_campaign, only: [:show, :edit, :update, :destroy]
  before_filter :force_cache_reload, :only => [:new]
  before_filter :store_purchase_session, only: [:purchase]
  respond_to :html

  def index
    @campaigns = Campaign.all.page
    respond_with(@campaigns)
  end

  def show
    # respond_with(@campaign)
  end

  def new
    # prefill model attributes if session saved
    # code is a little messy b/c we don't know which questions/choices have values and which don't
    # we could also just count the ones that have values first and iterate twice, once for w/ and then w/o

    """
    IMPORTANT! 
    """
    # note that some tags will be model independent in the form--we also have to fill those in
    if session[:campaign].present?
      # get campaign attributes
      @campaign = Campaign.new(session['campaign'].except('questions_attributes','number_questions','age_range_option')) # exclude nested models
      # iterate through number of questions
      (Campaign.max_num_questions).times do |i|
        # get each question attributes
        question_attributes = session['campaign']['questions_attributes'][i.to_s] || {}
        question = @campaign.questions.new(question_attributes.except('choices_attributes')) # exclude nested models
        # iterature through number of choices
        (Question.max_num_options).times do |j|
          # get each choice attributes
          choice_attributes = (question_attributes.present?) ? question_attributes['choices_attributes'][j.to_s].except('image') : {}
          question.choices.new(choice_attributes)
        end
      end
    else
      @campaign = Campaign.new
      (Campaign.max_num_questions).times do
        question = @campaign.questions.build # build empty model for questions
        (Question.max_num_options).times { question.choices.build } # build empty model for choices
      end
    end
    respond_with(@campaign)
  end

  def edit
  end

  def create
    # @campaign = Campaign.new(campaign_params)
    # @campaign.save

    # respond_with(@campaign)
  end

  def purchase

    """
    PARAMS MODIFICATION
    """

    # modifying params for creation
    purchase_params = campaign_params
    unless params[:age_range_option].nil?
      lower_age = (18 if params[:age_range_option] == "2") || 
                  (25 if params[:age_range_option] == "3") || 
                  (45 if params[:age_range_option] == "4") || 
                  (65 if params[:age_range_option] == "5") || 0
      upper_age = (17 if params[:age_range_option] == "1") || 
                  (24 if params[:age_range_option] == "2") || 
                  (44 if params[:age_range_option] == "3") || 
                  (64 if params[:age_range_option] == "4") || 99
      purchase_params.merge!(age_range_lower: lower_age, age_range_upper: upper_age)
    end
    purchase_params.merge!(researcher_id: current_researcher.id)
    purchase_params[:questions_attributes].each do |index, question|
      if params[:number_questions].to_i < (index.to_i + 1) # don't try and validate hidden questions
        break
      end
      num_choices = question[:choices_attributes].count{|index, choice| choice["text"].present?}
      num_images = question[:choices_attributes].count{|index, choice| choice["image"].present?}
      multiple_choice =  num_choices > 0
      # for now just enforce multiple_choice
      if !multiple_choice
        flash[:error] = "All your questions need to have at least one answer"
        flash[:error] += " (you were not charged for your questions, nor were they created)."
        redirect_to new_campaign_path and return
      elsif question[:use_images] == "0" and num_choices > 2
        flash[:error] = "You can only provide two answers for image questions"
        flash[:error] += " (you were not charged for your questions, nor were they created)."
        redirect_to new_campaign_path and return   
      elsif question[:use_images] == "0" and num_images > 0
        flash[:error] = "You provided images for a question but did not select to use images."
        flash[:error] += " (you were not charged for your questions, nor were they created)."
        redirect_to new_campaign_path and return                
      end

      question.merge!({limit: purchase_params[:limit], 
                       alpha_id: generate_alpha_id(Question),
                       multiple_choice: multiple_choice})
    end

    Campaign.transaction do 

      begin

        """
        VALIDATIONS
        """

        # some custom validations for the purchase path
        # a little hacky to do it here, but simplest for now
        # i probably want to restrict to this method anyway, and not site-wide
        num_present_questions = purchase_params[:questions_attributes].count{|index, question| question["text"].present?}
        if params[:number_questions].to_f < 1 or num_present_questions < 1
          raise "Number of questions must be at least one"
        elsif params[:number_questions].to_f > Campaign.max_num_questions or num_present_questions > Campaign.max_num_questions
          raise "Number of questions in one campaign can be at most #{Campaign.max_num_questions}"
        elsif num_present_questions != params[:number_questions].to_f
          raise "Number of questions selected did not match number actually submitted."
        end # also see multiple choice validation above and model validation below


        """
        CAMPAIGN CREATION
        """

        # create actual questions
        @campaign = Campaign.new(purchase_params)
        @campaign.save
        # cleaner would be to combine the save and update
        # but this lets me avoid creating another hash to calc price
        cost = (@campaign.price * params[:number_questions].to_f * campaign_params[:limit].to_f)
        taxes = params[:tax_state].to_f * cost
        total_cost = cost + taxes
        @campaign.update(cost: cost, taxes: taxes)

        if @campaign.errors.any?
          raise "Error creating campaign: #{@campaign.errors.full_messages.join('; ')}"
        end

        """
        STRIPE
        """

        # shortcircuit if admin
        if current_researcher.admin
          # return
        end

        customer = Stripe::Customer.create(
          :email => params[:stripeEmail],
          :card  => params[:stripeToken]
        )

        charge = Stripe::Charge.create(
          :customer    => customer.id,
          :amount      => (total_cost * 100).to_i, # in cents
          :description => 'hellotoken question payment',
          :currency    => 'usd'
        )

        """
        CLEANUP
        """

        session[:campaign] = nil
        # also add rendering or status stuff here

      rescue => e
        flash[:error] = e.to_s
        flash[:error] += " (you were not charged for your questions, nor were they created)"
        redirect_to new_campaign_path
        raise ActiveRecord::Rollback # revert transaction
        return
      end

    end

    # renders create.html.erb at the end
    
  end

  def update
    @campaign.update(campaign_params)
    respond_with(@campaign)
  end

  def destroy
    # @campaign.destroy
    # respond_with(@campaign)
  end

  # a wrapper method for the store purchase method
  def save_session
    # runs check_researcher filter, but can also add other auth validations
    # render nothing: true
  end

  private
    def set_campaign
      @campaign = Campaign.find(params[:id])
    end

    def campaign_params
      campaign_params = params.require(:campaign)
                              .permit(:title, :limit, :target_age, :target_gender, :target_categories,
                                      :target_male, :target_female, :target_other, :researcher_id,
                                      :complete, :age_range_lower, :age_range_upper,
                                      category_ids: [],
                                      questions_attributes: [:text, :use_images, :random,
                                        choices_attributes: [:text, :image ]]
                                      )
      return campaign_params
    end

    def store_purchase_session
      # basically, just store the strong param in a session to remember the form
      session[:campaign] = campaign_params
      session[:campaign][:number_questions] = params[:number_questions]
      session[:campaign][:age_range_option] = params[:age_range_option]
    end
end
