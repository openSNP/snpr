# frozen_string_literal: true
class AddDescriptionColumnsToPhenotype < ActiveRecord::Migration
  def self.up
    add_column :phenotypes, :description,    :text
  end

  def self.down
    remove_column :phenotypes, :description
  end
end