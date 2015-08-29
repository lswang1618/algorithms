class Researchers::RegistrationsController < Devise::RegistrationsController
  # disable default no_authentication action
  # skip_before_action :require_no_authentication, only: [:new, :create, :cancel]
  # now we need admin to register new admin
  # prepend_before_action :authenticate_scope!, only: [:new, :create, :cancel]
  before_filter :configure_permitted_parameters

  def sign_up(resource_name, resoure)
    sign_in(resource_name, resource)
  end

  def after_inactive_sign_up_path_for(resource)
    '/confirm'
  end

  # we'll be using this action instead of the native researchers#update method (which is designed for admins)
  # since it's simpler to have email and password updating (a devise specialty) in the same form as everything else
  # it's commented and only here as reference since the inherited update method is actually perfectly fine
  # def update
  # end

  protected

    # stay on the edit path after updating 
    def after_update_path_for(resource)
      edit_researcher_registration_path
    end

  private

    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up) do |u|
        u.permit(:full_name,
          :email, :password, :password_confirmation, :terms_of_service)
      end 
    end

    def account_update_params
      params.require(:researcher).permit(:name, :email, :password, :password_confirmation, :current_password,
                                         :company_name, :website, :logo_text_hex, :logo_background_hex, 
                                         :use_custom_colors)
    end


end
