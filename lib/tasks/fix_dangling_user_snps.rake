namespace :user_snps do
  task delete_dangling: :environment do
    UserSnp.where('user_id not in (select id from users)').find_each do |u|
      UserSnp.delete(u.id)
    end
  end
end
