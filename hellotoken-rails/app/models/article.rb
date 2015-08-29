class Article < ActiveRecord::Base
  has_many :responses
  has_many :questions, through: :article_questions
  # has_many :readers, through: :visits
  belongs_to :publisher

  def self.remove_www(url)
    # assumes no suffixes like .co.uk b/c those mess up period count
    if url.count('.') > 1 and url[0...3] == 'www'
      return url[4..-1]
    end
    return url
  end

  def self.popup_visit(article_hash, publisher)
    article = Article.find_or_create_by(domain: Article.remove_www(article_hash[:domain]), 
                                        path: article_hash[:path])
    article.url = article.domain + article.path if article.url.nil? # handle old articles
    if article.publisher_id.nil?
      article.publisher_id = publisher.id
    end
    article.increment(:visits)
    article.save
    return article
  end

  def money_responses
    if publisher.free_demographics
      money_responses = self.responses.joins(:question).where(questions: {demographic: nil, test: false})
    else
      money_responses = self.responses.joins(:question).where(questions: {test: false})
    end
  end

  def format_url
    http_url = (url[0,4] == "http") ? url : "http://"+url
    return http_url
  end 

  def update_num_responses
    self.update(num_responses: self.responses.count)
  end


end