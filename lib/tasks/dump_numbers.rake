require 'date'
require 'active_support/core_ext/integer/time'
namespace :numbers do
	desc "dump numbers for R plots"
	task :dump => :environment do
		# check whether directory for dump exists or create
		Dir.mkdir("#{Rails.root}/public/data/plot_data/") unless File.exists?("#{Rails.root}/public/data/plot_data/")

		curr_week_i = 0
		# start with getting users
		# curr_user is the first user in each week
		curr_user = User.first!
		u_by_week, week_labels = [1], [js_format_record(curr_user)]

		File.open("#{Rails.root}/public/data/plot_data/number_users.csv","w") { |file|
			User.find_each.with_index do |u, i|
				# CSVs only for R image generation
				# NOTE efficient but a little funky to do this w/semi-unreleated file open
				file.write("#{i + 1}\t#{u.created_at}\n")

				next if i == 1

				# now prepare js plot data
				if in_same_week(curr_user, u)
					u_by_week[curr_week_i] += 1
				else
					curr_user = u
					curr_week_i += 1
					u_by_week[curr_week_i] = 1 + u_by_week[curr_week_i - 1]
					week_labels[curr_week_i] = js_format_record(curr_user)
				end

			end
		}

		File.open("#{Rails.root}/public/data/plot_data/number_users.js", "w") { |file|
			str_rep = "#{week_labels.zip(u_by_week)}"
			str_rep.gsub!('"', '')
			file.write("var WEEKLY_USERS = #{str_rep};")
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
	
	# true <==> a, b created in same week
	def in_same_week(a, b)
		a_date = a.created_at.to_date
		b_date = b.created_at.to_date
		return ((a_date.cweek == b_date.cweek) && (a_date.year == b_date.year))
	end

	def js_format_record(r)
		rd = r.created_at.to_date
		return "new Date(#{rd.year}, #{rd.mon}, #{rd.mday})"
	end

end
