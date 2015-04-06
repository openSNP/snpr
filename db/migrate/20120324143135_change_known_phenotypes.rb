class ChangeKnownPhenotypes < ActiveRecord::Migration
  def self.up
    change_column :phenotypes, :known_phenotypes, :text
  end

  def self.down
    change_column :phenotypes, :known_phenotypes, :text
  end
end
