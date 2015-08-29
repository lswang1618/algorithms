class ConfirmationsController < Devise::ConfirmationsController

  def after_confirmation_path_for(resource_name, resource)
  	if resource.verified?
  		dashboard_path
  	else 
    	'/thanks'
    end
  end

end