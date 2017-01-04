# frozen_string_literal: true
class AddIndexesOnSnpsAndUsersnps < ActiveRecord::Migration
  def self.up
    add_index :snps, :name
    add_index :user_snps, :snp_name
  end

  def self.down
    remove_index :snps, :name
    remove_index :user_snps, :snp_name
  end
end
