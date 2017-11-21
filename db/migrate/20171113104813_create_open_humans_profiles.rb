# frozen_string_literal: true

class CreateOpenHumansProfiles < ActiveRecord::Migration
  def self.up
    create_table :open_humans_profiles do |t|
      t.string :open_humans_user_id
      t.string :project_member_id
      t.belongs_to :user
      t.string :access_token
      t.string :refresh_token
      t.timestamp :expires_in
      t.timestamps
    end
  end

  def self.down
    drop_table :open_humans_profiles
  end
end
