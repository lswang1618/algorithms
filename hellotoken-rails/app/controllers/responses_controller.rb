class ResponsesController < ApplicationController
  before_action :set_response, only: [:show, :edit, :update, :destroy]
  before_action :check_admin, except: [:create]
  respond_to :html, :js

  def index
    # logger.debug "PAGE: #{params[:page]}"
    # logger.debug "STRONG: #{response_params}"
    # logger.debug "SEARCH: #{search_params}"
    # @responses = Response.where(search_params).order(created_at: :desc).page(params[:page]).per(10)


    @q = Response.where(response_params).ransack(params[:q]) # by default, ransack accepts all columns
    #@q.sorts = 'created_at desc' if @q.sorts.empty? # default sorting order
    @responses = @q.result.includes(:question, :choice, :reader, :article).page(params[:page]).per(10)
    respond_with(@responses)
  end

  def show
    # respond_with(@response)
  end

  def new
    # @response = Response.new
    # respond_with(@response)
  end

  def edit
  end

  def create
    @response = Response.new(response_params)

    respond_to do |format|
      if @response.save
        format.json { render json: {response: @response} }
      end
    end
  end

  def update
    # @response.update(response_params)
    # respond_with(@response)
  end

  def destroy
    # @response.destroy
    # respond_with(@response)
  end

  private
    def set_response
      @response = Response.find(params[:id])
    end

    def response_params
      if params[:response].nil? # handle cases where we haven't searched yet
        return {}
      end
      params.require(:response).permit(:text,:article,
                                      :question_id,:reader_id,
                                      :article_id, :choice_id)
    end
end
