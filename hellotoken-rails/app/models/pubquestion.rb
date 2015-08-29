class Pubquestion < ActiveRecord::Base
  belongs_to :publisher
  belongs_to :researcher
end
