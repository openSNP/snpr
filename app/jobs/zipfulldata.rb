require 'resque'

class Zipfulldata
  queue = :zipfulldata

  def self.perform(target_address)
    Rails.logger.level = 0
    Rails.logger = Logger.new("#{Rails.root}/log/zipfulldata_#{Rails.env}.log")

    genotypes = Genotype.includes(user: :user_phenotypes).all

    # only try to create csv & zip-file if there is data at all.

    if genotypes != []
      time = Time.now.utc
      time_str = time.strftime("%Y%m%d%H%M")
      time = time.to_s.gsub(":","_")

      csv_options = { col_sep: ';' }

      # only create a new file if in the current minute none has been created yet

      unless File.exists?("#{Rails.root}/public/data/zip/opensnp_datadump.#{time_str}.zip")

        create_user_csv(genotypes, time_str, csv_options)
        create_fitbit_csv(time_str, csv_options)
        list_of_pics = create_user_picture_phenotype_csv(time_str, csv_options)
        create_picture_zip(list_of_pics, time_str)
        create_readme(time_str, time)

        # zip up everything (csv + all genotypings + pics-zip + pics-csv + readme)

        zipname = "/data/zip/opensnp_datadump."+time_str+".zip"
        Zip::ZipFile.open(::Rails.root.to_s+"/public/"+zipname, Zip::ZipFile::CREATE) do |zipfile|
          zipfile.add("picture_phenotypes_" + time_str.to_s + ".csv", ::Rails.root.to_s+"/tmp/picture_dump"+time_str.to_s+".csv")
          zipfile.add("picture_phenotypes_" + time_str.to_s + "_all_pics.zip", ::Rails.root.to_s + "/public/" + pic_zipname)
          zipfile.add("phenotypes_"+time_str.to_s+".csv",::Rails.root.to_s+"/tmp/dump"+time_str.to_s+".csv")
          zipfile.add("readme.txt",::Rails.root.to_s+"/tmp/dump"+time_str.to_s+".txt")
          genotypes.each do |gen_file|
            yob = gen_file.user.yearofbirth
            sex = gen_file.user.sex
            if yob == "rather not say"
                yob = "unknown"
            end
            if sex == "rather not say"
                sex = "unknown"
            end
            zipfile.add("user"+gen_file.user_id.to_s+"_file"+gen_file.id.to_s+"_yearofbirth_"+yob+"_sex_"+sex+"."+gen_file.filetype+".txt", ::Rails.root.to_s+"/public/data/"+ gen_file.fs_filename)
          end

          fitbit_profiles.each do |fp|
            zipfile.add("user"+fp.user.id.to_s+"_fitbit_data_"+time_str.to_s+".csv",::Rails.root.to_s+"/tmp/dump_user"+fp.user.id.to_s+"_fitbit_data_"+time_str.to_s+".csv")
          end

        end
        if FileLink.find_by_description("all genotypes and phenotypes archive") == nil
            filelink = FileLink.new(:description => "all genotypes and phenotypes archive", :url => zipname)
            filelink.save
        else
            FileLink.find_by_description("all genotypes and phenotypes archive").update_attributes(:url => zipname)
        end

        File.delete(::Rails.root.to_s+"/tmp/dump"+time_str.to_s+".csv")
        File.delete(::Rails.root.to_s+"/tmp/dump"+time_str.to_s+".txt")
        fitbit_profiles.each do |fp|
          File.delete(::Rails.root.to_s+"/tmp/dump_user"+fp.user.id.to_s+"_fitbit_data_"+time_str.to_s+".csv")
        end
        log "created zip-file"
      end

      # make sure the file-permissions of the resulting zip-file are okay and send mail
      system("chmod 777 "+::Rails.root.to_s+"/public/data/zip/opensnp_datadump."+time_str+".zip")
      UserMailer.dump(target_address,"/data/zip/opensnp_datadump."+time_str+".zip").deliver
      log "sent mail"
    else
      UserMailer.no_dump(target_address).deliver
    end
  end

  def self.create_user_csv(genotypes, time_str, csv_options)
    phenotypes = Phenotype.all
    csv_head = %w(user_id date_of_birth chrom_sex)
    csv_head.concat(phenotypes.map(&:characteristic))

    CSV.open("#{Rails.root}/tmp/dump#{time_str}.csv", "w", csv_options) do |csv|
      csv << csv_head

      # create lines in csv-file for each user who has uploaded his data
      genotypes.each do |genotype|
        user = genotype.user
        row = [user.id, user.yearofbirth, user.sex]

        phenotypes.each do |phenotype|
          if up = user.user_phenotypes.where(phenotype_id: phenotype.id).first
            row << up.variation
          else
            row << "-"
          end
        end
        csv << row
      end
    end
    log "created csv-file"
  end

  def self.create_fitbit_csv(time_str, csv_options)
    # Create a file of fitbit-data for each user with fitbit-data
    fitbit_profiles = FitbitProfile.
      includes(:fitbit_activities, :fitbit_bodies, :fitbit_sleeps).all
    fitbit_profiles.each do |fp|
      csv_header = ['date', 'steps', 'floors', 'weight', 'bmi',
                    'minutes asleep', 'minutes awake', 'times awaken',
                    'minutes until fell asleep']

      CSV.open("#{Rails.root}/tmp/dump_user#{fp.user.id}_fitbit_data_#{time_str}.csv","w", csv_options) do |csv|

        # get all dates which have to be included in the csv

        bodies = fp.fitbit_bodies.group_by(&:date_logged)
        sleeps = fp.fitbit_sleeps.group_by(&:date_logged)
        activities = fp.fitbit_activities.group_by(&:date_logged)

        time_array = []
        time_array.concat(bodies.keys)
        time_array.concat(sleeps.keys)
        time_array.concat(activities.keys)
        time_array = time_array.uniq.sort

        time_array.each do |d|
          row = [d]

          activity = activities[d]
          if activity.present?
            activity = activity.first
            row.concat([activity.steps, activity.floors])
          else
            row.concat(%w(- -))
          end

          body = bodies[d]
          if body.present?
            body = body.first
            row.concat([body.weight, body.bmi])
          else
            row.concat(%w(- -))
          end

          sleep = sleeps[d]
          if sleep.present?
            sleep = sleep.first
            row.concat([sleep.minutes_asleep, sleep.minutes_awake,
                        sleep.number_awakenings, sleep.minutes_to_sleep])
          else
            row.concat(%w(- - - -))
          end

          csv << row
        end
      end
      log "Saved fibit-date for "
    end
  end

  # make a CSV describing all of them - which filename is for which user's phenotype
  def self.create_user_picture_phenotype_csv(time_str, csv_options)
    file_name = "#{Rails.root}/tmp/picture_dump#{time_str}.csv"
    log "Writing picture-CSV to #{file_name}"

    list_of_pics = [] # need this for the zip-file-later

    picture_phenotypes = PicturePhenotype.all
    csv_head = %w(user_id date_of_birth chrom_sex)
    csv_head.concat(picture_phenotypes.map(&:characteristic))

    CSV.open(file_name, "w", csv_options) do |csv|

      csv << csv_head

      # create lines in csv-file for each user who has uploaded his data


      User.includes(:user_picture_phenotypes).all.each do |u|
        log "Looking at user #{u.id}"
        row = [u.id, u.yearofbirth, u.sex]
        picture_phenotypes.each do |up|

          # copy the picture with name to +user_id+_+pic_phenotype_id+.png
          log "Looking for this picture #{up.id}"
          picture = u.user_picture_phenotypes.
            where(picture_phenotypes_id: up.id).first
          # does this user have this pic?
          if picture.present?
            file_name = picture.phenotype_picture.path
            basename = file_name.split("/")[-1]
            filetype = basename.split(".")[-1]
            log "FOUND file #{file_name}, basename is #{basename}"

            list_of_pics << picture
            row << "#{picture.id}.#{filetype}"
          else
            row << '-'
          end
        end
        log "Putting a line into CSV"
        csv << row
      end
    end
    log "created picture handle csv-file"
    list_of_pics
  end

  def self.create_picture_zip(list_of_pics, time_str)
    pic_zipname = "/data/zip/opensnp_picturedump."+time_str+".zip"
    Zip::ZipFile.open("#{Rails.root}/public/#{pic_zipname}", Zip::ZipFile::CREATE) do |z|
      list_of_pics.each do |tmp|
        begin
          file_name = tmp.phenotype_picture.path
          basename = file_name.split("/")[-1]
          filetype = basename.split(".")[-1]
          log "Adding file to zip named #{tmp.id.to_s + "." + filetype}"
          z.add(tmp.id.to_s+"."+filetype, file_name)
          log "Added #{tmp.id.to_s + "." + filetype}"
        rescue
          log "missing file"
        end
      end
    end

    log "created picture zip file"
  end
  
  def self.create_readme(time_str, time)
    # make a README containing time of zip - this way, users can compare with page-status
    # and see how old the data is
    phenotype_count = Phenotype.count
    genotype_count = Genotype.count
    picture_count = PicturePhenotype.count
    File.open("#{Rails.root}/tmp/dump#{time_str}.txt", "w") do |readme|
      readme.puts(<<-TXT)
This archive was generated on #{time} UTC. It contains #{phenotype_count} phenotypes, #{genotype_count} genotypes and #{picture_count} picture phenotypes.

Thanks for using openSNP!
TXT
    end
  end

  def self.log msg
      Rails.logger.info "#{DateTime.now}: #{msg}"
  end
end
