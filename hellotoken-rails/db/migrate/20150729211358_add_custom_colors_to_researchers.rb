class AddCustomColorsToResearchers < ActiveRecord::Migration
  def change
    add_column :researchers, :use_custom_colors, :boolean, default: true
  end
end
