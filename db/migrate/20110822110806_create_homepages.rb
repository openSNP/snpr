class CreateHomepages < ActiveRecord::Migration
  def self.up
	  create_table :homepages do |h|
		  h.text :url
		  h.text :description
		  h.timestamps
		  h.belongs_to :user
	  end
  end

  def self.down
	  drop_table :homepages
  end
end
