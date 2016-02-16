namespace :numbers do
  desc "dump numbers for R plots"
  task :dump => :environment do
    # check whether directory for dump exists or create
    Dir.mkdir("#{Rails.root}/public/data/plot_data/") unless File.exists?("#{Rails.root}/public/data/plot_data/")    
    # start with getting users
    counter = 0
    File.open("#{Rails.root}/public/data/plot_data/number_users.csv","w"){ |file|
      User.find_each do |u|
        counter += 1
        file.write("#{counter}\t#{u.created_at}\n")
      end
    }

    # now let's get the genotypes
    counter = 0
    File.open("#{Rails.root}/public/data/plot_data/number_genotypes.csv","w"){ |file|
      Genotype.find_each do |u|
        counter += 1
        file.write("#{counter}\t#{u.created_at}\n")
      end
    }

    # what else do we need? oh yes, phenotypes
    counter = 0
    File.open("#{Rails.root}/public/data/plot_data/number_phenotypes.csv","w"){ |file|
      Phenotype.find_each do |u|
        counter += 1
        file.write("#{counter}\t#{u.created_at}\n")
      end
    }

    # and lastly the user phenotypes
    counter = 0
    File.open("#{Rails.root}/public/data/number_user_phenotypes.csv","w"){ |file|
      UserPhenotype.find_each do |u|
        counter += 1
        file.write("#{counter}\t#{u.created_at}\n")
      end
    }
  end
end
