class Choice < ActiveRecord::Base
  belongs_to :question
  has_many :responses
  validates :text, length: {maximum: 50} # arbitrary
  validates_presence_of :question, inverse_of: :choices

  has_attached_file :image, 
    styles: {
      icon: "450x80>!",#450x80>!
      medium: "500x500  "
    },
    convert_options: {
      icon: '-set colorspace sRGB -strip',
      medium: '-set colorspace sRGB -strip'
    },
    default_url: "ht_logo_small.png" # change to "test/insert here.png"    

  validates_attachment :image, 
    :content_type => { :content_type => /^image\/(jpeg|png|gif|tiff)$/ }

  def percent_of_answers
    return (self.responses.size.to_f / [self.question.responses.size,1].max)
  end

end
