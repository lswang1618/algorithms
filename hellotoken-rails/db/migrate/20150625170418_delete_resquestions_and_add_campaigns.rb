class DeleteResquestionsAndAddCampaigns < ActiveRecord::Migration
  def change
    drop_table :resquestions
    create_table :campaigns do |t|
      t.string :category
      t.timestamps null: false
    end
  end
end
