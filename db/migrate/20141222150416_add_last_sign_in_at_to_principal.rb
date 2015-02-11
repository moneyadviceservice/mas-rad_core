class AddLastSignInAtToPrincipal < ActiveRecord::Migration
  def change
    add_column :principals, :last_sign_in_at, :datetime
  end
end
