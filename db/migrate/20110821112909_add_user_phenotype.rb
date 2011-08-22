class AddUserPhenotype < ActiveRecord::Migration
  def self.up
	  create_table :user_phenotypes do |up|
		  up.belongs_to :user
		  up.belongs_to :phenotype
		  up.string :variation
		  up.timestamps
	  end
  end

  def self.down
	  drop_table :user_phenotypes
  end
end
