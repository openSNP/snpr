class CreateHomepages < ActiveRecord::Migration
  def self.up
	  create_table :homepages do |h|
		  h.string :url
		  h.string :description
		  h.timestamps
		  h.belongs_to :user
	  end
  end

  def self.down
	  drop_table :homepages
  end
end
