# frozen_string_literal: true
class CreateFitbitSleeps < ActiveRecord::Migration
  def self.up
	  create_table :fitbit_sleeps do |t|
		  t.belongs_to :fitbit_profile
		  t.string :minutes_asleep
      t.string :minutes_awake
      t.string :number_awakenings
      t.string :minutes_to_sleep
      t.string :date_logged
		  t.timestamps
	  end
  end

  def self.down
  	drop_table :fitbit_sleeps
  end
  
end
