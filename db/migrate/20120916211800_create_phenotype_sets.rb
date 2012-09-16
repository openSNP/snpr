class CreatePhenotypeSets < ActiveRecord::Migration
  def self.up
	  create_table :phenotype_sets do |t|
		  t.belongs_to :user
		  t.string :title
		  t.text :description
		  t.timestamps
	  end
  end

  def self.down
  	drop_table :phenotype_sets
  end
  
end
