require 'date'
require 'active_support/core_ext/integer/time'
namespace :numbers do
	desc "dump numbers for JS and R plots"
	task :dump => :environment do
		# check whether directory for dump exists or create
		Dir.mkdir("#{Rails.root}/public/data/plot_data/") unless File.exists?("#{Rails.root}/public/data/plot_data/")


		# assumes now after then
		def weeks_between(now, _then)
			return ((now - _then) / 7).floor
		end

		def js_format_record(rd)
			return "new Date(#{rd.year}, #{rd.mon}, #{rd.mday})"
		end

		def make_week_labels(n_wks, first_date)
			labels = Array.new(n_wks)
			labels.map!.with_index {	|x, i|
				js_format_record(first_date + (7 * i))
			}
			return labels
		end

		# fills nxw arr with historical values
		def sum_fill(arr)
			w = arr[0].size
			if w.nil?
				raise 'arr not 2d'
			end
			hist = Array.new(w){0}
			for i in 0 ... arr.size
				for j in 0 ... w
					arr[i][j] ||= hist[j]
					if hist[j] != arr[i][j]
						hist[j] += arr[i][j]
					end
				end
			end
			return arr
		end


		# ignore geno date since can't have geno's until after 1st user!
		first_user_date = User.first!.created_at.to_date
		ug_n_wks = weeks_between(User.last!.created_at.to_date, first_user_date) + 1

		ug_labels = make_week_labels(ug_n_wks, first_user_date)

		# format is [number users, number genos]
		users_and_geno = Array.new(ug_n_wks){ Array.new(2) }
		curr_n_users = 0

		# get number of users
		File.open("#{Rails.root}/public/data/plot_data/number_users.csv", "w") { |file|
			User.find_each.with_index do |u, i|
				# CSVs for R image generation only
				# NOTE efficient but a little funky to do this w/semi-unreleated file open
				file.write("#{i + 1}\t#{u.created_at}\n")

				curr_n_users += 1
				i = weeks_between(u.created_at.to_date, first_user_date)
				users_and_geno[i][0] = curr_n_users
			end
		}


		curr_n_genos = 0

		# now let's get the genotypes
		File.open("#{Rails.root}/public/data/plot_data/number_genotypes.csv", "w") { |file|
			Genotype.find_each.with_index do |u, i|
				file.write("#{i + 1}\t#{u.created_at}\n")

				curr_n_genos += 1
				i = weeks_between(u.created_at.to_date, first_user_date)
				users_and_geno[i][1] = curr_n_genos
			end
		}

		# users and genos VS time
		File.open("#{Rails.root}/public/data/plot_data/number_users.js", "w") { |file|
			str_rep = "#{ug_labels.zip(*(sum_fill(users_and_geno)).transpose)}"
			str_rep.gsub!('"', '')
			file.write("var USERS_GENOS_VS_TIME = #{str_rep};")
		}



		# what else do we need? oh yes, phenotypes
		first_pheno_date = Phenotype.first!.created_at.to_date
		pp_n_wks = weeks_between(Phenotype.last!.created_at.to_date, first_pheno_date) + 1
		pp_labels = make_week_labels(pp_n_wks, first_pheno_date)

		# format is [number phenos, number user phenos]
		pheno_and_upheno = Array.new(pp_n_wks){ Array.new(2) }
		curr_n_pheno = 0

		File.open("#{Rails.root}/public/data/plot_data/number_phenotypes.csv", "w"){ |file|
			Phenotype.find_each.with_index do |u,i|
				file.write("#{i + 1}\t#{u.created_at}\n")

				curr_n_pheno += 1
				i = weeks_between(u.created_at.to_date, first_pheno_date)
				pheno_and_upheno[i][0] = curr_n_pheno
			end
		}

		curr_n_upheno = 0

		# and lastly the user phenotypes
		File.open("#{Rails.root}/public/data/plot_data/number_user_phenotypes.csv", "w"){ |file|
			UserPhenotype.find_each.with_index do |u,i|
				file.write("#{i + 1}\t#{u.created_at}\n")

				curr_n_upheno += 1
				i = weeks_between(u.created_at.to_date, first_pheno_date)
				pheno_and_upheno[i][1] = curr_n_upheno
			end
		}

		# phenos and user phenos VS time
		File.open("#{Rails.root}/public/data/plot_data/number_pheno.js", "w") { |file|
			str_rep = "#{pp_labels.zip(*(sum_fill(pheno_and_upheno)).transpose)}"
			str_rep.gsub!('"', '')
			file.write("var PHENO_USER_PHENO_VS_TIME = #{str_rep};")
		}


		puts "done!"

	end
end
