class ChoicesController < ApplicationController
  before_action :set_choice, only: [:show, :edit, :update, :destroy]
  before_action :check_admin

  respond_to :html, :js

  def index
    @choices = Choice.where(choice_params).includes(:question).page(params[:page]).per(10)
    respond_with(@choices)
  end

  def show
    respond_with(@choice)
  end

  def new
    # @choice = Choice.new
    # respond_with(@choice)
  end

  def edit
  end

  def create
    # @choice = Choice.new(choice_params)
    # @choice.save
    # respond_with(@choice)
  end

  def update
    # @choice.update(choice_params)
    # respond_with(@choice)
  end

  def destroy
    # @choice.destroy
    # respond_with(@choice)
  end

  private
  def set_choice
    @choice = Choice.find(params[:id])
  end

  def choice_params
    if params[:choice].nil?
      return {}
    end
    params.require(:choice).permit(:question_id)
  end
end
