class CreatePhenotypeComments < ActiveRecord::Migration
  def self.up
	  create_table :phenotype_comments do |t|
		  t.text :comment_text
		  t.text :subject
		  t.belongs_to :user
		  t.belongs_to :phenotype
		  t.integer :reply_to_id
		  t.timestamps
	  end
  end

  def self.down
	  drop_table :phenotype_comments
  end
end
