class AddUserSnpsCount < ActiveRecord::Migration
  def up
    add_column :snps, :user_snps_count, :integer
    Snp.reset_column_information
    user_snp_counts = execute(
      'select snp_name, count(*) as count from user_snps group by snp_name'
    ).to_a.reduce({}) { |m, us| m[us['snp_name']] = us['count']; m }
    Snp.find_each do |s|
      s.user_snps_count = user_snp_counts[s.name]
      s.save!
    end
  end

  def down
    remove_column :snps, :user_snps_count
  end
end
