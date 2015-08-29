# Controls routes related to popup and the JS in iframe called by plugin
class PopupController < ApplicationController

  skip_before_action :verify_authenticity_token, only: [:index, :checkPublisherID, :ping] #if :json_request? seems to break things
  after_action :allow_iframes, only: [:index]

  layout 'popup'

  def submit
    choice_id = params["response"].keys[0]

    response = Response.create(text: params["response"][choice_id],
                    choice_id: choice_id.to_i,
                    question_id: params["question_id"].to_i,
                    article_id: params["article_id"].to_i,
                    reader_id: params["reader_id"].to_i,
                    full_url: params["full_url"])

    if params["demographic"].present?
      reader = Reader.find(params["reader_id"])
      reader.update_demographics({params["demographic"] => params["response"][choice_id]}) unless reader.nil?
    end
    head :created, location: '/popup/submit'
  end

  def index

    # much later: refactor so that all server stuff starts here
    # render html: "<script>window.parent.postMessage('close no pass', document.referrer);</script>".html_safe

    # get the url and details of the referring path (i.e. url of plugin location)

    """
    PUBLISHER AND ARTICLE VALIDATION
    """

    article_hash = {
      url: request.referrer,
      path: URI(request.referrer).path,
      domain: URI(request.referrer).host
    }
    logger.info "Processing request from: #{article_hash}"

    # Check if clientID from plugin exists
    @publisher = Publisher.find_by(alpha_id: params[:clientID], verified: true) # grab publisher from clientID
    if @publisher.nil? or !@publisher.is_valid_domain(article_hash[:domain])
      postMessage('close no pass', status: 401) # skip view render
      logger.info "Bad or no clientID given"
      return
    end

    @article = Article.popup_visit(article_hash, @publisher)
    @full_article_url = request.referrer

    if !@publisher.questions_active
      postMessage('close no pass') # skip view render
      logger.info "Questions for this publisher inactive."
      return
    end 

    """

    READER

    """

    reader_id = getCookie('ht-user') || "" # get reader id; set to blank string if nil
    # Find reader if exists, otherwise create
    results = Geocoder.search(request.remote_ip)
    if geocode = results.first
      logger.info {"Successfully retrieved geocode data for reader: #{geocode.data}"}
    else
      logger.error {"Error retrieving geocode data for reader"} unless geocode.present?
    end
    @reader = Reader.popup_visit(alpha_id: reader_id, ip: request.remote_ip, page: @article.url, geocode: geocode)
    setCookie('ht-user', @reader.alpha_id, 365)
    reader_demographics = @reader.get_demographics # get demographics in a hash

    """

    TARGETING QUESTIONS

    """

    @question = Question.get_demographic_question(reader_demographics) # get a question to find demographics if appropriate
    if @question.present?
      @choices = @question.choices
      @researcher = @question.campaign.researcher
      return # short circuit
    end

    """

    TARGETED QUESTIONS

    """

    @category = if @publisher.nil? then nil else @publisher.category end # grab publisher's category
    @campaigns = Campaign.eligible_campaigns(@category,@reader) # grab eligible campaigns
    @questions = Question.eligible_questions(@campaigns,@reader,(params[:mode] == "demo")) # grab eligible questions
    # order questions if you want the same one each time
    @question = @questions.sample # like this: questions.sort(blank); or above like this: article.questions.order(blank)
    if @question.nil?
      logger.info {"No questions found. Posting empty question data."}
      postMessage('close no pass', status: 204) # skip view render
      return
    else
      @choices = @question.choices
      @researcher = @question.campaign.researcher
      logger.info {"#{@questions.length} question(s) found. Randomly selected question #{@question.alpha_id}."}
    end

  rescue => e
    logger.error {"Error loading questions for modal: #{e}"}
    postMessage('close no pass', status: 500)

  end

  def ping
    respond_to do |format|
      format.js do
        render json: {}, callback: params[:callback]
      end
    end
  end

  # validate that the given publisher alpha id exists
  # used in conjunction with plugin settings page, where client ID is set
  def checkPublisherID
    begin
      publisher = Publisher.find_by(alpha_id: params[:publisher_alpha_id], verified: true) # grab publisher from clientID
      logger.info "publisher url: #{params['publisher_url']}"
      publisher_url = params['publisher_url']
      publisher_domain = URI(publisher_url).host
      @valid = (publisher.present? and publisher.is_valid_domain(publisher_domain))
      logger.info {"Request has valid client id: #{@valid}"}
      respond_to do |format|
        format.js do
          render json: @valid, callback: params[:callback]
        end
      end
    rescue => e
      respond_to do |format|
        format.js do
          render json: false, callback: params[:callback]
        end
      end
    end
  end

  private
  def postMessage(msg, status: 200)
    render html: ("<script>window.parent.postMessage('" + msg + "', document.referrer);</script>").html_safe, status: status
  end

  def allow_iframes
    response.headers['X-Frame-Options'] = 'ALLOWALL'
  end

end
