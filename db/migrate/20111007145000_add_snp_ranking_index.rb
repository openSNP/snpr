# frozen_string_literal: true
class AddSnpRankingIndex < ActiveRecord::Migration  
  def self.up
    add_index :snps, %i(ranking), name: 'index_snps_ranking'
  end
  
  def self.down
    remove_index :snps, %i(ranking)
  end
end
