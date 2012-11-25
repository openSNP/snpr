class CreatePicturePhenotypes < ActiveRecord::Migration
  def self.up
	  create_table :picture_phenotypes do |p|
		  p.string :characteristic  # e.g. haircolor
		  p.string :description # longer text explaining what people should upload & why it's interesting
		  p.integer :number_of_users, :default => 0
		  p.timestamps
	  end
  end

  def self.down
	  drop_table :picture_phenotypes
  end
end
