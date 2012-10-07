class CreateGenomeGovPapers < ActiveRecord::Migration
  def self.up
    create_table :genome_gov_papers do |t|
      t.text :first_author
      t.text :title
      t.text :pubmed_link
      t.text :pub_date
      t.text :journal
      t.text :trait
      t.float :pvalue
      t.text :pvalue_description
      t.text :confidence_interval
      t.timestamps 
      t.belongs_to :snp
    end
  end
  
  def self.down
    drop_table :genome_gov_papers
  end
end