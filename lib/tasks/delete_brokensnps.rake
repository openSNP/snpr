# delete broken snps of user

namespace :snps do
  desc 'delete broken snps'
  task delete: :environment do
    Snp.where('id >= 1941594 and id <= 1956090').find_each do |s|
      s.user_snps.each do |us|
        puts 'delete user-snp: ' + us.snp_name
        UserSnp.delete(us)
      end
      puts 'delete snp: ' + s.name
      Snp.delete(s)
    end
  end
end
