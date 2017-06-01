# frozen_string_literal: true
class AddUserSnpIndex < ActiveRecord::Migration  
  def self.up
    add_index :user_snps, [:snp_name,:user_id], name: "index_user_snps_on_user_id_and_snp_name"
  end
  
  def self.down
    remove_index :user_snps, [:snp_name,:user_id], name: "index_user_snps_on_user_id_and_snp_name"
  end
end