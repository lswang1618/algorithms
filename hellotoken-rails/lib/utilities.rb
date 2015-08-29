# General utilities for global use.
module Utilities
  def generate_alpha_id(myclass)
    id = SecureRandom.urlsafe_base64(10)
    while myclass.exists?(alpha_id: id)
      id = SecureRandom.urlsafe_base64(10)
    end
    return id
  end  
end

