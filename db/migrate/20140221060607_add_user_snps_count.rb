class AddUserSnpsCount < ActiveRecord::Migration
  def up
    add_column :snps, :user_snps_count, :integer, :default => 0
    Snp.reset_column_information
    Snp.find_each do |s|
      Snp.reset_counters s.id, :user_snps
    end
  end

  def down
    remove_column :snps, :user_snps_count
  end
end
