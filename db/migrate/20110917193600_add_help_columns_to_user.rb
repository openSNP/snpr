# frozen_string_literal: true
class AddHelpColumnsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :help_one,    :boolean, :default => false
    add_column :users, :help_two, :boolean, :default => false
    add_column :users, :help_three, :boolean, :default => false 
  end

  def self.down
    remove_column :users, :help_one
    remove_column :users, :help_two
    remove_column :users, :help_three
  end
end