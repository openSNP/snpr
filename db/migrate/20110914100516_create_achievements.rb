class CreateAchievements < ActiveRecord::Migration
  def self.up
		create_table :achievements do |p|
		  p.string :type  # e.g. "has entered more than 25 
		 end
	end

  def self.down
  end
end
