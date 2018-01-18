# frozen_string_literal: true
class RemoveFitbit < ActiveRecord::Migration
  def self.up
    drop_table :fitbit_activities
    drop_table :fitbit_sleeps
    drop_table :fitbit_bodies
    drop_table :fitbit_profiles
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
