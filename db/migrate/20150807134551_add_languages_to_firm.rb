class AddLanguagesToFirm < ActiveRecord::Migration
  def change
    add_column :firms, :languages, :text, array: true, null: false, default: []
  end
end
