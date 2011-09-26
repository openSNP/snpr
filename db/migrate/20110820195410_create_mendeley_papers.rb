class CreateMendeleyPapers < ActiveRecord::Migration
  def self.up
    create_table :mendeley_papers do |t|
      t.text :first_author
      t.text :title
      t.text :mendeley_url
      t.text :doi
      t.integer :pub_year
      t.string :uuid
      t.boolean :open_access
      t.integer :reader
      t.timestamps 
      t.belongs_to :snp
    end
  end
  
  def self.down
    drop_table :mendeley_papers
  end
end