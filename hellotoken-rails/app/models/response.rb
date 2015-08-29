class Response < ActiveRecord::Base
  belongs_to :question, counter_cache: :num_responses
  belongs_to :choice, counter_cache: :num_responses
  belongs_to :reader
  belongs_to :article, counter_cache: :num_responses

  # has_many :publishers, through: :question
  # has_many :researchers, through: :question

  after_create :update_completion_numbers
  after_destroy :update_completion_numbers

  def update_completion_numbers
    self.question.update_completion
    self.question.campaign.update_completion
    self.article.update_num_responses
  end

  # alias the publisher
  def publisher
    self.article.publisher
  end

end
