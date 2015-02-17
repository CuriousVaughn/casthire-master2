class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string   :email,                      :null => false, :unique  => true
      t.string   :password_digest,            :null => false
      t.integer  :kind,                       :null => false, :default => 0
      t.string   :auth_token,                 :null => false, :unique  => true
      t.string   :confirmation_token,         :null => false, :unique  => true
      t.datetime :confirmed_at
      t.string   :password_reset_token
      t.datetime :password_reset_sent_at

      t.timestamps
    end

    add_index :users, [:email],      :unique => true
    add_index :users, [:auth_token], :unique => true
  end
end
