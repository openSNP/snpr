class CreatePhenotypeComments < ActiveRecord::Migration
  def self.up
	  create_table :phenotype_comments do |t|
		  t.string :comment_text
		  t.string :subject
		  t.belongs_to :user
		  t.belongs_to :phenotype
		  t.timestamps
	  end
  end

  def self.down
	  drop_table :phenotype_comments
  end
end
