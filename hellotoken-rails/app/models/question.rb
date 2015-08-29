class Question < ActiveRecord::Base
  # dealing with answers
  has_many :responses, dependent: :destroy
  has_many :readers, through: :responses
  # inverse_of is necessary for validates_presence_of to work
  # rails should be trying to find it heuristically anyway, but dependent option breaks it
  has_many :choices, dependent: :destroy, inverse_of: :question

  # dealing with publishers and locations
  # has_many :artquestions
  # has_many :articles, through: :artquestions
  # has_many :pubquestions
  # has_many :publishers, through: :pubquestions

  # dealing with researchers and targeting
  belongs_to :campaign, inverse_of: :questions

  validates :text, :limit, presence: true
  validates :text, length: {
    maximum: 250, # Arbitrary
  }
  validates_presence_of :campaign
  validates_inclusion_of :demographic, in: (Reader::DEMOGRAPHICS), allow_blank: true, allow_nil: true

  class_attribute :max_num_options
  self.max_num_options = 5
  class_attribute :max_num_images, instance_writer: false
  self.max_num_images = 2

  accepts_nested_attributes_for :choices, :reject_if => lambda { |a| a[:text].blank? }, limit: Question.max_num_options

  # Internal: Find questions to fill in demographics
  #
  # demographics - Hash of demographic values for reader
  #
  # Examples
  #
  # question = Question.get_demographic_questions({"age" => nil, "gender" => "male"})
  # question.demographic
  # # => "age"
  #
  # Returns question for first blank demographic, or nil if demographics set or no valid questions found
  def self.get_demographic_question(demographics)
    demographics.each do |demographic, value|
      if value.nil?
        question = Question.find_by(demographic: demographic, over: false, test: false)
        # though over should never be true for a demographic question...
        if question.present?
          Rails.logger.info {"#{demographic.titleize} question found. Serving question #{question.alpha_id}."}
          return question
        end
      end
    end
    return nil
  end

  # Internal: Find eligible questions based on campaign and reader
  #
  # campaigns - The records of the campaigns questions can belong to
  # reader - The record of the reader questions should be tailored for
  #
  # Examples
  #
  # Question.eligible_questions(Campaign.all, Reader.first)
  #
  # Returns collection of eligible questions, or none if none found
  def self.eligible_questions(campaigns, reader, demo)
    questions = Question.where(campaign_id: campaigns.ids)
    questions = questions.where.not(id: reader.question_ids)
    questions = questions.where(over: false, test: false)
    if questions.empty? and demo
      questions = Question.where(test: true)
      Rails.logger.info "Demo mode detected. Serving test question."
    end
    return questions
  end

  def update_completion
    self.over = (self.num_responses > self.limit and self.limit != -1)
    self.save
  end

  # alias for researcher
  def researcher
    self.campaign.researcher
  end
end
