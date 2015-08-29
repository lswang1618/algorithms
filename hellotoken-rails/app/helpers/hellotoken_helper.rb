module HellotokenHelper
  def resource_name
    (@type == "researcher") ? :researcher : :publisher
  end

  def resource
    if @type == "researcher"
      @resource ||= Researcher.new
    else
      @resource ||= Publisher.new
    end
    return @resource
  end

  def devise_mapping
    if @type == "researcher"
      @devise_mapping ||= Devise.mappings[:researcher]
    else
      @devise_mapping ||= Devise.mappings[:publisher]
    end
  end

end
