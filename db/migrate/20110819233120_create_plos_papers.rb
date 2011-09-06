class CreatePlosPapers < ActiveRecord::Migration
  def self.up
    create_table :plos_papers do |t|
      t.string :first_author
      t.string :title
      t.string :doi
      t.timestamp :pub_date
      t.timestamps 
      t.integer :reader
      t.belongs_to :snp
    end
  end
  
  def self.down
    drop_table :plos_papers
  end
end