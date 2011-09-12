class CreateSnps < ActiveRecord::Migration
  def self.up
	  create_table :snps do |t|
		  t.string :name
		  t.string :position
		  t.string :chromosome
		  t.string :genotype_frequency
		  t.string :allele_frequency
		  t.integer :ranking
		  t.integer :number_of_users
		  t.timestamp :mendeley_updated, :default => Time.zone.now-3000000
		  t.timestamp :plos_updated, :default => Time.zone.now-3000000
		  t.timestamp :snpedia_updated, :default => Time.zone.now-3000000
		  t.timestamps
	  end

	  add_index :snps, [:id], :name => "index_snps_on_id", :unique => true
  end

  def self.down
  	drop_table :snps
  end
end
