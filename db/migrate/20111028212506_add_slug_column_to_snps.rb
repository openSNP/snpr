class AddSlugColumnToSnps < ActiveRecord::Migration
  def self.up
    add_column :snps, :slug, :string
    add_index :snps, :slug, :unique => true
  end

  def self.down
    remove_column :snps, :slug
  end
end