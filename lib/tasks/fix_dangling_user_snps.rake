namespace :user_snps do
  task :delete_dangling => :environment do
    UserSnp.where("user_id not in (select id from users)").each do |u|
      puts u.user_id
    end
  end
end
