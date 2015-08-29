class ChangeAgeColumnInReaders < ActiveRecord::Migration
    def up
      change_column :readers, :age, :string
    end

    def down
      change_column :readers, :age, :integer
    end
end
