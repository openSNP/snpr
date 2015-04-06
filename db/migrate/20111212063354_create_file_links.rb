class CreateFileLinks < ActiveRecord::Migration
  def self.up
    create_table :file_links do |f|
      f.text :description
      f.text :url
      f.timestamps
    end
  end

  def self.down
    drop_table :file_links
  end
end
