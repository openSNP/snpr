# frozen_string_literal: true
class ChangeSnpForeignKeyForUserSnps < ActiveRecord::Migration
  def self.up
    add_column :user_snps, :snp_name, :string
    snps = Snp.select('id, name').all.inject({}) { |hash, snp| hash.merge(snp.id => snp.name) }
    user_snps = UserSnp.all
    user_snps.each { |user_snp| user_snp.update_attribute(:snp_name, snps[user_snp.snp_id]) }
  end

  def self.down
    remove_column :user_snps, :snp_name
  end
end
