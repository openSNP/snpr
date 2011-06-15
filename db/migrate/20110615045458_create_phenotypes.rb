class CreatePhenotypes < ActiveRecord::Migration
  def self.up
	  create_table :phenotypes do |p|
		  p.string :variations # e.g. haircolor
		  p.references :user # we need the foreign key

	  end
  end

  def self.down
	  drop_table :phenotypes
  end
end
