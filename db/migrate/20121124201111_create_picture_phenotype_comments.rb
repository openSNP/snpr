# frozen_string_literal: true
class CreatePicturePhenotypeComments < ActiveRecord::Migration
  def self.up
	  create_table :picture_phenotype_comments do |t|
		  t.text :comment_text
		  t.text :subject
		  t.belongs_to :user
		  t.belongs_to :picture_phenotype
		  t.integer :reply_to_id
		  t.timestamps
	  end
  end

  def self.down
	  drop_table :picture_phenotype_comments
  end
end
