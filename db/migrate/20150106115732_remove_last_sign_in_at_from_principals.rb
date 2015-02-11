class RemoveLastSignInAtFromPrincipals < ActiveRecord::Migration
  def change
    remove_column :principals, :last_sign_in_at
  end
end
