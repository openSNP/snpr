class CreateAchievements < ActiveRecord::Migration
  def self.up
		create_table :achievements do |p|
		  p.text :award  # e.g. "has entered more than 25 
		  p.string :short_name
			p.timestamps
		 end
	end

  def self.down
		drop_table :achievements
  end
end
