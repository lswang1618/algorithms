class ResearchersController < ApplicationController
  before_action :set_researcher, only: [:show, :edit, :update, :destroy]
  before_action :check_admin

  respond_to :html, :js

  # GET /researchers
  # GET /researchers.json
  def index
    @researchers = Researcher.all.page(params[:page])
    respond_with(@researchers)
  end

  # GET /researchers/1
  # GET /researchers/1.json
  def show
    @campaigns = @researcher.campaigns
    @questions = @researcher.questions
  end

  """
  Don't confuse the next few methods with the Registrations controller methods for Devise!
  These are intended for admin use--the Registrations controller methods are designed for user use.
  """

  # GET /researchers/new
  def new
    # @researcher = Researcher.new
  end

  # GET /researchers/1/edit
  def edit
  end

  # POST /researchers
  # POST /researchers.json
  def create
    # disable this feature for now
    # @researcher = Researcher.new(researcher_params)

    # respond_to do |format|
    #   if @researcher.save
    #     format.html { redirect_to @researcher, notice: 'Researcher was successfully created.' }
    #     format.json { render :show, status: :created, location: @researcher }
    #   else
    #     format.html { render :new }
    #     format.json { render json: @researcher.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # PATCH/PUT /researchers/1
  # PATCH/PUT /researchers/1.json
  def update
    @researcher.skip_reconfirmation!
    respond_to do |format|
      if @researcher.update_without_password(researcher_params)
        format.html { redirect_to @researcher, notice: 'Researcher was successfully updated.' }
        format.json { render :show, status: :ok, location: @researcher }
      else
        format.html { render :edit }
        format.json { render json: @researcher.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /researchers/1
  # DELETE /researchers/1.json
  def destroy
    @researcher.destroy
    respond_to do |format|
      format.html { redirect_to researchers_url, notice: 'Researcher was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_researcher
      if params[:id] == "sign_out"
        flash[:error] = "There was a connection error while signing out. Please try again."
        redirect_to root_path and return 
      end
      @researcher = Researcher.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def researcher_params
      params.require(:researcher).permit(:email, :password, 
                                        :website, :name, :company_name, :admin, 
                                        :verified, :use_custom_colors, :logo_text_hex,
                                        :logo_background_hex)
    end
end
