class CreateFitbitActivities < ActiveRecord::Migration
  def self.up
	  create_table :fitbit_activities do |t|
		  t.belongs_to :fitbit_profile
		  t.string :steps
      t.string :floors
      t.string :date_logged
		  t.timestamps
	  end
  end

  def self.down
  	drop_table :fitbit_activities
  end
  
end
