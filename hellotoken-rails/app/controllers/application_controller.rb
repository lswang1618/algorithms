class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  def generate_alpha_id(myclass)
    id = SecureRandom.urlsafe_base64(10)
    while myclass.exists?(alpha_id: id)
      id = SecureRandom.urlsafe_base64(10)
    end
    return id
  end

  private

    # anyone signed in?
    def user_signed_in?
      return (researcher_signed_in? or publisher_signed_in?)
    end 

    # check both signed in and verified 
    def check_researcher
      if !researcher_signed_in?
        redirect_to invalid_path
        return
      end
      if !current_researcher.verified?
        redirect_to waiting_path
      end
    end

    def check_publisher
      if !publisher_signed_in?
        redirect_to invalid_path
        return
      end
      if !current_publisher.verified?
        redirect_to waiting_path
      end
    end

    # complete check for both signed in and verified
    def check_allowed_persons
      if researcher_signed_in?
        if !current_researcher.verified?
          redirect_to waiting_path
        end
        return
      elsif publisher_signed_in?
        if !current_publisher.verified?
          redirect_to waiting_path
        end
        return
      else
        redirect_to invalid_path
      end
    end
  
    def check_admin
      if !(researcher_signed_in? and current_researcher.admin)
        redirect_to invalid_path and return
      end
    end

    def setCookie(name, value, num_days)
      cookies.encrypted[name] = {value: value, expires: num_days.days.from_now}
      return cookies.encrypted[name]
    end

    def getCookie(name)
      decrypted_cookie = "" 
      cookies[name].each_char {|c| decrypted_cookie += (69 ^ c.ord).chr} unless cookies[name].nil?
      return cookies.encrypted[name] || decrypted_cookie[1..-2] # handle the legacy structure from JS cookie setting
    end

    def force_cache_reload
      response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
      response.headers["Pragma"] = "no-cache"
      response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
    end

end
