class Category < ActiveRecord::Base
  has_and_belongs_to_many :campaigns
  has_many :publishers

  def self.get_blog_available_categories
    Category.includes(:publishers).where.not( :publishers => {id: nil})
  end
end
