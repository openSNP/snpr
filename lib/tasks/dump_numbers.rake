# frozen_string_literal: true
namespace :numbers do
  desc "dump numbers for R plots"
  task :dump => :environment do
    # check whether directory for dump exists or create
    Dir.mkdir("#{Rails.root}/public/data/plot_data/") unless File.exists?("#{Rails.root}/public/data/plot_data/")
    # start with getting users
    File.open("#{Rails.root}/public/data/plot_data/number_users.csv","w"){ |file|
      User.find_each.with_index do |u, i|
        file.write("#{i + 1}\t#{u.created_at}\n")
      end
    }

    # now let's get the genotypes
    File.open("#{Rails.root}/public/data/plot_data/number_genotypes.csv","w"){ |file|
      Genotype.find_each.with_index do |u,i|
        file.write("#{i + 1}\t#{u.created_at}\n")
      end
    }

    # what else do we need? oh yes, phenotypes
    File.open("#{Rails.root}/public/data/plot_data/number_phenotypes.csv","w"){ |file|
      Phenotype.find_each.with_index do |u,i|
        file.write("#{i + 1}\t#{u.created_at}\n")
      end
    }

    # and lastly the user phenotypes
    File.open("#{Rails.root}/public/data/plot_data/number_user_phenotypes.csv","w"){ |file|
      UserPhenotype.find_each.with_index do |u,i|
        file.write("#{i + 1}\t#{u.created_at}\n")
      end
    }
    puts "done!"
  end
end
