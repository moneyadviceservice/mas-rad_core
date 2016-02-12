class CreateSnapshots < ActiveRecord::Migration
  def change
    create_table :snapshots do |t|
      t.integer :firms_with_no_minimum_fee
      t.timestamps null: false
    end
  end
end
