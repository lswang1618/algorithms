class AddDefaultColorsForResearchers < ActiveRecord::Migration
  def change
  	change_column :researchers, :button_background_hex, :string, default: '#FFBF3F'
  	change_column :researchers, :button_text_hex, :string, default: '#FFFFFF'
  	rename_column :researchers, :button_background_hex, :logo_background_hex
  	rename_column :researchers, :button_text_hex, :logo_text_hex
  end
end
