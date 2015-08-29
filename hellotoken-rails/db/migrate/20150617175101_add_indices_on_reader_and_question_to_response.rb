class AddIndicesOnReaderAndQuestionToResponse < ActiveRecord::Migration
  def change
    add_index :responses, [:reader_id, :question_id]
  end
end
