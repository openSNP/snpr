# frozen_string_literal: true
class CreatePhenotypes < ActiveRecord::Migration
  def self.up
	  create_table :phenotypes do |p|
		  p.string :characteristic  # e.g. haircolor
		  p.string :known_phenotypes
		  p.integer :number_of_users, :default => 0
		  p.timestamps
	  end
  end

  def self.down
	  drop_table :phenotypes
  end
end
