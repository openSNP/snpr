class CreateAchievements < ActiveRecord::Migration
  def self.up
		create_table :achievements do |p|
		  p.string :award  # e.g. "has entered more than 25 
			p.timestamps
		 end
	end

  def self.down
		drop_table :achievements
  end
end
