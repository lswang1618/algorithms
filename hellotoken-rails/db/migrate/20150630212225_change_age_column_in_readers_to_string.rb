class ChangeAgeColumnInReadersToString < ActiveRecord::Migration
  def change

    def up
      change_column :readers, :age, :string
    end

    def down
      change_column :readers, :age, :integer
    end

  end
end
