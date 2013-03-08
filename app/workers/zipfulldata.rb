
require 'csv'

class Zipfulldata
  include Sidekiq::Worker
  sidekiq_options :queue => :zipfulldata

  attr_reader :time, :time_str, :csv_options, :dump_file_name, :zip_public_path,
    :zip_fs_path, :tmp_dir

  def perform(target_address)
    Rails.logger.level = 0
    Rails.logger = Logger.new("#{Rails.root}/log/zipfulldata_#{Rails.env}.log")
    log("job started")
    new.run(target_address)
    log("job done")
  end

  def initialize
    @time = Time.now.utc
    @time_str = time.strftime("%Y%m%d%H%M")
    @csv_options = { col_sep: ';' }
    @dump_file_name = "opensnp_datadump.#{time_str}"
    @zip_public_path = "/data/zip/#{dump_file_name}.zip"
    @zip_fs_path = "#{Rails.root}/public#{zip_public_path}"
    @tmp_dir = "#{Rails.root}/tmp/#{dump_file_name}"
  end

  def run(target_address)
    genotypes = Genotype.includes(user: :user_phenotypes).all

    # only try to create csv & zip-file if there is data at all.
    if genotypes.empty?
      UserMailer.no_dump(target_address).deliver
      return false
    end

    # only create a new file if in the current minute none has been created yet
    if Dir.exists?(tmp_dir)
      log "Directory #{tmp_dir} already exists. Exiting..."
      return false
    end

    begin
      Dir.mkdir(tmp_dir)
      Zip::ZipFile.open(zip_fs_path, Zip::ZipFile::CREATE) do |zipfile|
        create_user_csv(genotypes, zipfile)
        create_fitbit_csv(zipfile)
        list_of_pics = create_picture_phenotype_csv(zipfile)
        create_picture_zip(list_of_pics, zipfile)
        create_readme(zipfile)
        zip_genotype_files(genotypes, zipfile)
      end

      if FileLink.find_by_description("all genotypes and phenotypes archive").nil?
        filelink = FileLink.new(:description => "all genotypes and phenotypes archive", :url => zip_public_path)
        filelink.save
      else
        FileLink.find_by_description("all genotypes and phenotypes archive").update_attributes(:url => zip_public_path)
      end

      FileUtils.chmod(0755, "#{Rails.root}/public/data/zip/#{dump_file_name}.zip")
      UserMailer.dump(target_address, "/data/zip/#{dump_file_name}.zip").deliver
      log "created zip-file"

      # make sure the file-permissions of the resulting zip-file are okay and send mail
      log "sent mail"
    ensure
      FileUtils.rm_rf(tmp_dir)
    end
    true
  end

  def create_user_csv(genotypes, zipfile)
    phenotypes = Phenotype.all
    csv_file_name = "#{tmp_dir}/dump#{time_str}.csv"
    csv_head = %w(user_id date_of_birth chrom_sex)
    csv_head.concat(phenotypes.map(&:characteristic))

    CSV.open(csv_file_name, "w", csv_options) do |csv|
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
    log "created user csv"
    zipfile.add("phenotypes_#{time_str}.csv", csv_file_name)
  end

  def create_fitbit_csv(zipfile)
    # Create a file of fitbit-data for each user with fitbit-data
    fitbit_profiles = FitbitProfile.
      includes(:fitbit_activities, :fitbit_bodies, :fitbit_sleeps).all
    fitbit_profiles.each do |fp|
      csv_file_name =
        "#{tmp_dir}/dump_user#{fp.user.id}_fitbit_data_#{time_str}.csv"
      csv_header = ['date', 'steps', 'floors', 'weight', 'bmi',
                    'minutes asleep', 'minutes awake', 'times awaken',
                    'minutes until fell asleep']
      CSV.open(csv_file_name, "w", csv_options) do |csv|
        csv << csv_header
        bodies = fp.fitbit_bodies.group_by(&:date_logged)
        sleeps = fp.fitbit_sleeps.group_by(&:date_logged)
        activities = fp.fitbit_activities.group_by(&:date_logged)

        # get all dates which have to be included in the csv
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
      zipfile.add("user#{fp.user.id}_fitbit_data_#{time_str}.csv", csv_file_name)
      log "Saved fibit-date for "
    end
  end

  # make a CSV describing all of them - which filename is for which user's phenotype
  def create_picture_phenotype_csv(zipfile)
    file_name = "#{tmp_dir}/picture_dump#{time_str}.csv"
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
        picture_phenotypes.each do |pp|

          # copy the picture with name to +user_id+_+pic_phenotype_id+.png
          log "Looking for this picture #{pp.id}"
          picture = pp.user_picture_phenotypes.where(user_id: u.id).first
          # does this user have this pic?
          if picture.present? && picture.phenotype_picture.present?
            picture_path = picture.phenotype_picture.path
            basename = picture_path.split("/")[-1]
            filetype = basename.split(".")[-1]
            log "FOUND file #{picture_path}, basename is #{basename}"

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
    zipfile.add("picture_phenotypes_#{time_str}.csv", file_name)
    list_of_pics
  end

  def create_picture_zip(list_of_pics, zipfile)
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
        rescue => e
          log "create_picture_zip: #{e.class}: #{e.message}"
        end
      end
    end
    zipfile.add("picture_phenotypes_#{time_str}_all_pics.zip",
                "#{Rails.root}/public/#{pic_zipname}")
    log "created picture zip file"
  end

  def create_readme(zipfile)
    # make a README containing time of zip - this way, users can compare with page-status
    # and see how old the data is
    phenotype_count = Phenotype.count
    genotype_count = Genotype.count
    picture_count = PicturePhenotype.count
    File.open("#{tmp_dir}/dump#{time_str}.txt", "w") do |readme|
      readme.puts(<<-TXT)
This archive was generated on #{time.ctime} UTC. It contains #{phenotype_count} phenotypes, #{genotype_count} genotypes and #{picture_count} picture phenotypes.

Thanks for using openSNP!
TXT
    end
    zipfile.add("readme.txt", "#{tmp_dir}/dump#{time_str}.txt")
  end

  def zip_genotype_files(genotypes, zipfile)
    genotypes.each do |gen_file|
      yob = gen_file.user.yearofbirth
      sex = gen_file.user.sex
      if yob == "rather not say"
          yob = "unknown"
      end
      if sex == "rather not say"
          sex = "unknown"
      end
      zipfile.add("user#{gen_file.user_id}_file#{gen_file.id}_yearofbirth_#{yob}_sex_#{sex}.#{gen_file.filetype}.txt",
                  "#{Rails.root}/public/data/#{gen_file.fs_filename}")
    end
  end

  def log(msg)
    self.class.log(msg)
  end

  def log(msg)
    Rails.logger.info "#{DateTime.now}: #{msg}"
  end
end
