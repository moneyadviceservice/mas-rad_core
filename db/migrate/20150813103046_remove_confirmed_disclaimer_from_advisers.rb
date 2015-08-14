class RemoveConfirmedDisclaimerFromAdvisers < ActiveRecord::Migration
  def change
    remove_column :advisers, :confirmed_disclaimer, :boolean, null: false
  end
end
