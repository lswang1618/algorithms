class AddArticleRefToResponses < ActiveRecord::Migration
  def change
    add_reference :responses, :article, index: true
  end
end
