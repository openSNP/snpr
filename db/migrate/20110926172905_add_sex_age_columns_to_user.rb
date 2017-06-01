# frozen_string_literal: true
class AddSexAgeColumnsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :sex,    :string, default: "rather not say"
    add_column :users, :yearofbirth, :string, default: "rather not say"
  end

  def self.down
    remove_column :users, :sex
    remove_column :users, :yearofbirth
  end
end