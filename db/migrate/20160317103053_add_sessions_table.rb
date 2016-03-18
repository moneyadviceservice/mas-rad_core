class AddSessionsTable < ActiveRecord::Migration
  def change
    create_table :rad_consumer_sessions do |t|
      t.string :session_id, :null => false
      t.text :data
      t.timestamps
    end

    add_index :rad_consumer_sessions, :session_id, :unique => true
    add_index :rad_consumer_sessions, :updated_at
  end
end
