class CreateFitbitProfiles < ActiveRecord::Migration
  def self.up
    create_table :fitbit_profiles do |t|
      t.string :fitbit_user_id
      t.belongs_to :user
      t.string :request_token
      t.string :request_secret
      t.string :access_token
      t.string :access_secret
      t.string :verifier
      t.boolean :body, default: true
      t.boolean :activities, default: true
      t.boolean :sleep, default: true
      t.timestamps
    end
  end

  def self.down
    drop_table :fitbit_profiles
  end
end
