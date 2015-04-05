class RemoveSlugColumnFromSnps < ActiveRecord::Migration
  def self.up
    remove_column :snps, :slug
  end

  def self.down
    'nothing to do'
  end
end
