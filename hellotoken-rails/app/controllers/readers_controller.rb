class ReadersController < ApplicationController
  before_action :set_reader, only: [:show, :edit, :update, :destroy]
  before_action :check_admin

  respond_to :html, :js

  def index
    @readers = Reader.where(reader_params).includes(:responses).order(created_at: :desc).page(params[:page]).per(10)
    @reader_stats = Reader.get_demographic_stats
    respond_with(@readers)
  end

  def show
    respond_with(@reader)
  end

  def new
    # @reader = Reader.new
    # respond_with(@reader)
  end

  def edit
  end

  def create
    # @reader = Reader.new(reader_params)
    # @reader.save
    # respond_with(@reader)
  end

  def update
    # @reader.update(reader_params)
    # respond_with(@reader)
  end

  def destroy
    # @reader.destroy
    # respond_with(@reader)
  end

  private
    def set_reader
      @reader = Reader.find(params[:id])
    end

    def reader_params
      if params[:reader].nil?
        return {}
      end
      params.require(:reader).permit(:gender, :age,
                                    :city, :region, :country,
                                    :last_page, :initial_page
                                    )
    end
end
