class CreateFitbitBodies < ActiveRecord::Migration
  def self.up
    create_table :fitbit_bodies do |t|
      t.belongs_to :fitbit_profile
      t.string :date_logged
      t.string :weight
      t.string :bmi
      t.timestamps
    end
  end

  def self.down
    drop_table :fitbit_bodies
  end
end
