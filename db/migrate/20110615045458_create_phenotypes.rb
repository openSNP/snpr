class CreatePhenotypes < ActiveRecord::Migration
  def self.up
	  create_table :phenotypes do |p|
		  p.string :characteristic  # e.g. haircolor
		  p.string :variation # e.g. blonde
		  p.references :user # we need the foreign key
		  p.timestamps

	  end
  end

  def self.down
	  drop_table :phenotypes
  end
end
