class DashboardController < ApplicationController
  include PayPal::SDK::OpenIDConnect

  before_filter :check_allowed_persons, except: [:waiting]
  before_filter :check_publisher, only: [:payout, :download_plugin]

  def index
    if researcher_signed_in?
      researcher_dashboard
      render 'researcher_dashboard' # could just redirect, but this saves time of browser request
    elsif publisher_signed_in?
      publisher_dashboard
      render 'publisher_dashboard'      
    end
  end

  def researcher_dashboard
    @campaigns = current_researcher.campaigns.limit(30).order(:created_at => :desc)
    @questions = current_researcher.questions.limit(1000).includes(:responses,:choices,:readers)
  end

  def publisher_dashboard
    if current_publisher.incomplete_payouts.any? and flash[:warning].blank?
      flash.now[:warning] = "You have incomplete payouts. Please log in to your PayPal account and complete your payouts from hellotoken.\n"
      flash.now[:warning] += "Incomplete payouts will expire after 30 days.\n"
      flash.now[:warning] += "Contact support@hellotoken.com if you have any other questions."
    end

    @responses = current_publisher.money_responses

    @total_views = [@responses.size, 0].max # fix divide by 0 error for no views
    @rev_per_view = 0.03
    @total_earnings = @rev_per_view*@total_views
    @paid_amount = current_publisher.paid
    @unpaid_amount = @total_earnings - @paid_amount
    @minimum_payment = current_publisher.minimum_payout
    # Should be a width of 100%, but doing 99% in case rounding error so it doesn't occupy 2 lines
    @full_bar_width = 99
    @unpaid_bar_width = @unpaid_amount / @minimum_payment * @full_bar_width
    @background_bar_width = (@minimum_payment - @unpaid_amount) / @minimum_payment * @full_bar_width
    @past_30_views = @responses.where('responses.created_at > ?', 30.days.ago).size
    @past_30_total_earnings = @rev_per_view*@past_30_views

    @paypal_auth_path = Tokeninfo.authorize_url( :scope => "openid email" )

    @articles = current_publisher.articles.order(num_responses: :desc).limit(15)
  end

  def waiting
    if researcher_signed_in?
      if current_researcher.verified?
        flash[:success] = "You're already verified. Start using your dashboard here!"
        redirect_to '/index' and return
      end
      render 'hellotoken/waiting' # replace once we have real content
    elsif publisher_signed_in?
      if current_publisher.verified?
        flash[:success] = "You're already verified. Start using your dashboard here!"
        redirect_to '/index' and return
      end
      publisher_waiting
      render 'publisher_waiting'
    else
      redirect_to invalid_path
    end
  end

  def publisher_waiting
  end

  def download_plugin
    send_file("#{Rails.root}/private/HelloToken-master.zip",
              filename: "ht-plugin.zip")
  end

  def payout
    paypal_auth_code = params[:code]

    if paypal_auth_code.blank?
      flash[:error] = "Please login through PayPal before doing that."
      redirect_to '/dashboard'
      return
    end

    # ensure publisher can actually pay out
    # this should happen only in malicious cases since I check for a code
    if !current_publisher.ready_for_payout? 
      flash[:error] = "You need to earn more before you can pay out."
      redirect_to '/dashboard'
      return
    end

    # ensure publisher has no payouts pending
    # this should happen only in malicious cases since I check for a code
    if current_publisher.incomplete_payouts.any? 
      flash[:error] = "You need to resolve your pending payouts first."
      redirect_to '/dashboard'
      return
    end

    begin
      if payout = current_publisher.payout(paypal_auth_code)
        if payout.status == "SUCCESS"
          flash[:success] = payout.get_status_message
        elsif payout.status == "UNCLAIMED"
          flash[:warning] = payout.get_status_message
        else 
          flash[:error] = payout.get_status_message
        end
      else
        raise ""
      end
    rescue => e
      logger.error {"Publisher #{current_publisher.id} failed to pay out succesfully."}
      logger.error {"#{e}"}
      flash[:error] = "There was an error paying out."
      flash[:error] += "\nIf problems persist, please contact support@hellotoken.com"
    end
    redirect_to '/dashboard'
  end

end
