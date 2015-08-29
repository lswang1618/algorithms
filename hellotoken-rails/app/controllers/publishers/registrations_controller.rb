class Publishers::RegistrationsController < Devise::RegistrationsController
  # disable default no_authentication action
  # skip_before_action :require_no_authentication, only: [:new, :create, :cancel]
  # now we need admin to register new admin
  # prepend_before_action :authenticate_scope!, only: [:new, :create, :cancel]
  before_filter :configure_permitted_parameters

  def sign_up(resource_name, resoure)
    sign_in(resource_name, resource)
    # flash[:message] = "You need to complete your account details.\n"
    # flash[:message] += "Once you do, we'll examine the details and verify your account."
    # edit_publisher_registration_path
  end

  def after_inactive_sign_up_path_for(resource)
    '/confirm'
  end

  def create
    # if account_update_params[:agree_to_tos] != 1
    #   flash[:error] = "You must agree to the terms of service."
    #   redirect_to :back and return
    # end
    super
  end

  # pass the categories to the form so the user can select them
  def edit
    @categories = Category.pluck(:name, :id)
    super
  end

  # we'll be using this action instead of the native publishers#update method (which is designed for admins)
  # since it's simpler to have email and password updating (a devise specialty) in the same form as everything else
  def update
    # don't ask me why this line is necessary
    # password confirmation breaks otherwise, so just do it
    @categories = Category.pluck(:name, :id)

    if params[:default_logo] == "1" # handle default logo before request gets sent to devise
      params[:publisher][:logo] = nil
    end

    super
  end

  protected

    # stay on the edit path after updating 
    def after_update_path_for(resource)
      edit_publisher_registration_path
    end

  private

    def account_update_params
      params.require(:publisher).permit(:name, :domain, :category_id, :email, 
                                        :password, :password_confirmation, :current_password,
                                        :logo, :blog_name, :default_logo)
    end

    def configure_permitted_parameters # I think sign_up_params works too, not sure
      devise_parameter_sanitizer.for(:sign_up) do |u|
        u.permit(:full_name,
          :email, :password, :password_confirmation, :terms_of_service)
      end 
    end

end
