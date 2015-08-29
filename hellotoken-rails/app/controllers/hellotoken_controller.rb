# Controls home page and static pages, as well as checking for sign-in
class HellotokenController < ApplicationController
  before_filter :check_signed_in, only: [:register, :login]
  before_filter :check_admin, only: [:admin, :logs]

  respond_to :html, :js
  def index
    # if user_signed_in?
    #   redirect_to '/dashboard'
    #   return
    # end
  end

  def order # what is this even here for?
    # respond_to do |format|
    #   format.html # new.html.erb
    #   format.json { render json: @poll }
    # end
  end

  def admin
    @publishers = Publisher.includes(:responses).order(:last_sign_in_at => :desc).page(params[:page]).per(10)
    @researchers = Researcher.order(:last_sign_in_at => :desc).page(params[:page]).per(10)
  end

  def logs
    @log_lines = `tail -n 200 ~/hellotoken-rails/shared/log/production.log`
    logger.debug "Log content: #{@log_lines}"
    # @log_lines = `tail -n 100 #{Rails.root.join('log', 'development.log')}`
  end

  private
  def check_signed_in
    # don't let users sign in twice
    if user_signed_in?
      redirect_to '/dashboard'
      return
    end
  end
end
