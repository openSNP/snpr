# frozen_string_literal: true
class CreatePhenotypeSetsPhenotypesJoinTable < ActiveRecord::Migration
  def self.up
    create_table :phenotype_sets_phenotypes, id: false do |t|
      t.integer :phenotype_set_id
      t.integer :phenotype_id
    end
  end

  def self.down
    drop_table :phenotype_sets_phenotypes
  end
  
end
