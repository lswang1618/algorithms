class Artquestion < ActiveRecord::Base
  belongs_to :article
  belongs_to :question
end
