class AddMd5sumToGenotyping < ActiveRecord::Migration
  def self.up
    add_column :genotypes, :md5sum, :string
  end

  def self.down
    remove_column :genotypes, :md5sum
  end
end
