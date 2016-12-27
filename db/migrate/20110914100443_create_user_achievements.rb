# frozen_string_literal: true
class CreateUserAchievements < ActiveRecord::Migration
  def self.up
 	  create_table :user_achievements do |t|
		  t.belongs_to :user
		  t.belongs_to :achievement
		  t.timestamps
	  end
  end

  def self.down
		drop_table :user_achievements
  end
end
