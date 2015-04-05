namespace :all do
  desc 'prints all created_at for all snps, genotypings, users, user_snps, phenotypes, user_phenotypes'
  task print: :environment do
    u_fh = open('users.txt', 'w')
    User.order(:created_at).each do |u|
      u_fh.write("#{u.id}\t#{u.created_at}\n")
    end
    g_fh = open('genotypes.txt', 'w')
    Genotype.order(:created_at).each do |u|
      g_fh.write("#{u.id}\t#{u.created_at}\n")
    end
    p_fh = open('phenotypes.txt', 'w')
    Phenotype.order(:created_at).each do |u|
      p_fh.write("#{u.id}\t#{u.created_at}\n")
    end
    up_fh = open('user_phenotypes.txt', 'w')
    UserPhenotype.order(:created_at).each do |u|
      up_fh.write("#{u.id}\t#{u.created_at}\n")
    end
  end
end
