class ChangeFitbitTypes < ActiveRecord::Migration
  def self.up
      change_column :fitbit_bodies, :weight, :float
      change_column :fitbit_bodies, :bmi, :float
      change_column :fitbit_activities, :steps, :int
      change_column :fitbit_activities, :floors, :int
      change_column :fitbit_sleeps, :minutes_awake, :int
      change_column :fitbit_sleeps, :minutes_asleep, :int
      change_column :fitbit_sleeps, :number_awakenings, :int
      change_column :fitbit_sleeps, :minutes_to_sleep, :int
      change_column :fitbit_sleeps, :date_logged, :date
      change_column :fitbit_bodies, :date_logged, :date
      change_column :fitbit_activities, :date_logged, :date
  end

  def self.down
      change_column :fitbit_bodies, :weight, :string
      change_column :fitbit_bodies, :bmi, :string
      change_column :fitbit_activities, :steps, :string
      change_column :fitbit_activities, :floors, :string
      change_column :fitbit_sleeps, :minutes_awake, :string
      change_column :fitbit_sleeps, :minutes_asleep, :string
      change_column :fitbit_sleeps, :number_awakenings, :string
      change_column :fitbit_sleeps, :minutes_to_sleep, :string
      change_column :fitbit_sleeps, :date_logged, :string
      change_column :fitbit_bodies, :date_logged, :string
      change_column :fitbit_activities, :date_logged, :string
  end
end
