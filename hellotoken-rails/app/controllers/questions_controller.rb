class QuestionsController < ApplicationController
  before_filter :check_researcher # make sure user is a researcher; exile them otherwise
  before_action :check_admin, except: [:show]
  before_action :set_question, only: [:show, :edit, :update, :destroy]

  respond_to :html, :js

  def index
    @questions = Question.where(question_params).includes(:responses, :campaign => :researcher ).page(params[:page]).per(10)
    respond_with(@questions)
  end

  def show
    respond_to do |format|
      if (@question.campaign.researcher_id == current_researcher.id or current_researcher.admin)
        format.html # show.html.erb
        format.js {render layout: false, content_type: 'text/javascript'} # show.js.erb
        # format.xml  { render :xml => @question }
        # format.json {render json: @question}
      else
        format.html {render html: "Access restricted for these questions."}
        format.js {render js: "alert('Access restricted for these questions.');"}
      end
    end
  end

  def new
  end

  def create
  end

  def edit
    # handle image questions not having 5 choices
    (Question.max_num_options - Question.max_num_images).times { @question.choices.build } if @question.use_images
  end

  def update
    # i should stick this in the question model
    num_choices = question_params[:choices_attributes].count{|index, choice| choice["text"].present?}
    num_images = question_params[:choices_attributes].count{|index, choice| choice["image"].present?}
    multiple_choice =  num_choices > 0
    if !multiple_choice
      flash[:error] = "All your questions need to have at least one answer"
      redirect_to edit_question_path(@question) and return
    elsif question_params[:use_images] == "1" and num_choices > 2
      flash[:error] = "You can only provide two answers for image questions"
      redirect_to edit_question_path(@question) and return   
    elsif question_params[:use_images] == "0" and num_images > 0
      flash[:error] = "You provided images for a question but did not select to use images."
      redirect_to edit_question_path(@question) and return                
    end

    @question.update(question_params)
    respond_with(@question)
  end

  private
    def set_question
      @question = Question.find(params[:id])
    end

    def question_params
      if params[:question].nil?
        return {}
      end
      params.require(:question).permit(:campaign_id,
                                      :over, 
                                      :limit, :test, :demographic,
                                      :text, :use_images, :random,
                                      choices_attributes: [:id, :text, :image ])
    end
end
