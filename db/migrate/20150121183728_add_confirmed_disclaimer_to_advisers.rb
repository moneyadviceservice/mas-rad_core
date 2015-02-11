class AddConfirmedDisclaimerToAdvisers < ActiveRecord::Migration
  def change
    add_column :advisers, :confirmed_disclaimer, :boolean, null: false
  end
end
