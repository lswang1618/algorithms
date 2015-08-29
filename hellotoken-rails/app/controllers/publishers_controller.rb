class PublishersController < ApplicationController
  before_action :set_publisher, only: [:show, :edit, :update, :destroy]
  before_action :check_admin

  respond_to :html, :js

  def index
    @publishers = Publisher.all.includes(:category).includes(:responses).page params[:page]
    respond_with(@publishers)
  end

  # GET /publishers/1
  # GET /publishers/1.json
  def show
    
  end

  """
  Don't confuse the next few methods with the Registrations controller methods for Devise!
  These are intended for admin use--the Registrations controller methods are designed for user use.
  """

  # GET /publishers/new
  def new
    # @publisher = Publisher.new
  end

  # GET /publishers/1/edit
  def edit
    @categories = Category.pluck(:name,:id)
  end

  # POST /publishers
  # POST /publishers.json
  def create
    # disabled for now
    # @publisher = Publisher.new(publisher_params)

    # respond_to do |format|
    #   if @publisher.save
    #     format.html { redirect_to @publisher, notice: 'Publisher was successfully created.' }
    #     format.json { render :show, status: :created, location: @publisher }
    #   else
    #     format.html { render :new }
    #     format.json { render json: @publisher.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # PATCH/PUT /publishers/1
  # PATCH/PUT /publishers/1.json
  def update
    @categories = Category.pluck(:name,:id)
    @publisher.skip_reconfirmation!
    if params[:default_logo]
      params[:logo] = nil
    end
    respond_to do |format|
      if @publisher.update_without_password(publisher_params)
        format.html { redirect_to @publisher, notice: 'Publisher was successfully updated.' }
        format.json { render :show, status: :ok, location: @publisher }
      else
        format.html { render :edit }
        format.json { render json: @publisher.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /publishers/1
  # DELETE /publishers/1.json
  def destroy
    # disabled for now
    # @publisher.destroy
    # respond_to do |format|
    #   format.html { redirect_to publishers_url, notice: 'Publisher was successfully destroyed.' }
    #   format.json { head :no_content }
    # end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_publisher
      # something is causing the application to turn :delete /signout requests to :get requests
      # here's minor patch to fix it when that happens
      if params[:id] == "sign_out"
        flash[:error] = "There was a connection error while signing out. Please try again."
        redirect_to root_path and return 
      end
      @publisher = Publisher.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def publisher_params
      params.require(:publisher).permit(:email, :name, 
                                        :domain, :password, :verified, 
                                        :blog_name, :category_id, :logo,
                                        :free_demographics, :questions_active)
    end
end
