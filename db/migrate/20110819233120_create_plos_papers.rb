class CreatePlosPapers < ActiveRecord::Migration
  def self.up
    create_table :plos_papers do |t|
      t.text :first_author
      t.text :title
      t.text :doi
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
