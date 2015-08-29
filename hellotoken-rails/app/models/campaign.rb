class Campaign < ActiveRecord::Base
  belongs_to :researcher
  has_many :questions, dependent: :destroy, inverse_of: :campaign
  has_many :responses, through: :questions
  has_and_belongs_to_many :categories

  validates :title, presence: true
  validates :title, length: {
    maximum: 30, # Arbitrary
  }
  validate :exceeds_minimum_cost

  # campaign cost constants, all in dollars
  class_attribute :prices, instance_writer: false
  self.prices = {
    base: 0.06,
    category: 0.04,
    gender: 0.04,
    age: 0.04
  }
  class_attribute :max_num_questions, instance_writer: false
  self.max_num_questions = 10
  class_attribute :min_order_cost, instance_writer: false
  self.min_order_cost = 10 # in dollars
  
  accepts_nested_attributes_for :questions, :reject_if => lambda { |a| a[:text].blank? }, limit: Campaign.max_num_questions

  # Internal: Find eligible campaigns based on category and reader demographics
  # 
  # category - The record of the category campaigns should come from
  # reader - The record of the reader with the appropriate demographics
  #
  # Examples
  # 
  # Reader.eligible_campaigns(Category.first, Reader.first)
  #
  # Returns collection of eligible campaigns, or none if none found

  def self.eligible_campaigns(category, reader)
    if category.nil?
      return Campaign.none
    end
    campaigns = category.campaigns.where(complete: false)
    demographics = reader.get_demographics
    demographics.each do |demographic, value|
      if campaigns.empty? # short circuit every round to save time
        return campaigns
      end
      if demographic.casecmp("gender") == 0 # this case ignore isn't needed, but I'm being paranoid
        if value.nil? # sigh...if it's nil it throws errors at casecmp; i'll deal with it better later
          campaigns = campaigns.where(target_gender: false)
        elsif value.casecmp("male") == 0
          campaigns = campaigns.where(target_male: true)
        elsif value.casecmp("female") == 0
          campaigns = campaigns.where(target_female: true)
        elsif value.casecmp("other") == 0
          campaigns = campaigns.where(target_other: true)
        else # covers nil and other values
          campaigns = campaigns.where(target_gender: false)
        end
      elsif demographic.casecmp("age") == 0 # more paranoia
        if value.nil?
          campaigns = campaigns.where(target_age: false)
        else
          age = value.to_i  # dumb string to int conversion
                            # many more cases will be needed eventually 
          campaigns = campaigns.where("age_range_lower <= ?", age).
                              where("age_range_upper >= ?", age)
        end
      end
    end
    if campaigns.empty?
      campaigns = category.campaigns.where(complete: false, all_publishers: true)
    end
    return campaigns
  end

  # alias the count
  def count
    self.responses.count
  end

  def price
    response_price = prices[:base]
    response_price += prices[:category] if target_categories
    response_price += prices[:gender] if target_gender
    response_price += prices[:age]if target_age
    return response_price
  end

  def self.price(target_hash)
    response_price = prices[:base]
    target_hash.each do |key, value|
      response_price += prices[key] if (target_hash[key])
    end
    return response_price
  end

  def exceeds_minimum_cost
    unless cost > Campaign.min_order_cost
      errors.add(:cost, "must be at least #{Campaign.min_order_cost} dollars")
    end
  end

  def update_completion
    self.update(complete: (self.responses.count > self.limit and self.limit != -1))
  end

end