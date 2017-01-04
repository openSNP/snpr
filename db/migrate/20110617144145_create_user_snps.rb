# frozen_string_literal: true
class CreateUserSnps < ActiveRecord::Migration
  def self.up
	  create_table :user_snps do |t|
	    t.string :local_genotype
		  t.belongs_to :genotype
		  t.belongs_to :user
		  t.belongs_to :snp
		  t.timestamps
	  end
  end

  def self.down
  	drop_table :user_snps
  end
  
end
