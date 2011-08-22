class CreateSnpediaPapers < ActiveRecord::Migration
  def self.up
	  create_table :snpedia_papers do |t|
		  t.string :url
		  t.timestamps
		  t.belongs_to :snp
	  end
  end

  def self.down
	  drop_table :snpedia_papers
  end
end
