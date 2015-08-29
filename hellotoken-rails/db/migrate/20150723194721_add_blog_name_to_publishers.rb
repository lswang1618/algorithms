class AddBlogNameToPublishers < ActiveRecord::Migration
  def change
    add_column :publishers, :blog_name, :string
  end
end
