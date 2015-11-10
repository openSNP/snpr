
require 'csv'
require 'zip'


class Zipfulldata
  include Sidekiq::Worker
  sidekiq_options :queue => :zipfulldata, :retry => 0, :unique => true, :dead => false
  # can't do retry => false.
  # Note with retry disabled, Sidekiq will not track or save any error data for the worker's jobs.
  # dead => false means don't send dead job to the dead queue, we don't care about that

  attr_reader :time, :time_str, :csv_options, :dump_file_name, :zip_public_path,
    :zip_fs_path, :tmp_dir, :link_path

  def perform
    Rails.logger.level = 0
    Rails.logger = Logger.new("#{Rails.root}/log/zipfulldata_#{Rails.env}.log")
    log("job started")
    run
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
    @link_path = Rails.root.join('public/data/zip/opensnp_datadump.current.zip')
  end

  def run
    genotypes = Genotype.includes(user: :user_phenotypes)
    log "Got #{genotypes.length} genotypes"

    # only create a new file if in the current minute none has been created yet
    if Dir.exists?(tmp_dir)
      log "Directory #{tmp_dir} already exists. Exiting..."
      return false
    end

    begin
      log "Making tmpdir #{tmp_dir}"
      Dir.mkdir(tmp_dir)
      log "Starting zipfile #{zip_fs_path}"
      Zip::File.open(zip_fs_path, Zip::File::CREATE) do |zipfile|
        create_user_csv(genotypes, zipfile)
        create_fitbit_csv(zipfile)
        list_of_pics = create_picture_phenotype_csv(zipfile)
        create_picture_zip(list_of_pics, zipfile)
        create_readme(zipfile)
        zip_genotype_files(genotypes, zipfile)
      end

      FileUtils.chmod(0644, "#{Rails.root}/public/data/zip/#{dump_file_name}.zip")
      log "created zip-file"

      FileUtils.ln_sf(
        Rails.root.join("public/data/zip/#{dump_file_name}.zip"),
        link_path)
        
      # everything went OK, now delete old zips
      delete_old_zips

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
      includes(:fitbit_activities, :fitbit_bodies, :fitbit_sleeps)
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

      User.includes(:user_picture_phenotypes).order(:id).each do |u|
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
    Zip::File.open("#{Rails.root}/public/#{pic_zipname}", Zip::File::CREATE) do |z|
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

  def delete_old_zips
    forbidden_files = [link_path, zip_fs_path, Rails.root.join("data/annotation.zip"), Rails.root.join("public/data/zip/#{dump_file_name}.zip")] 
    Dir[Rails.root.join('public/data/zip/*.zip')].each do |f|
      if (not forbidden_files.include? f) and (File.ftype(f) == "file")
        File.delete(f)
      end
    end
  end

  def log(msg)
    self.class.log(msg)
  end

  def log(msg)
    Rails.logger.info "#{DateTime.now}: #{msg}"
  end

  def self.public_path
    '/data/zip/opensnp_datadump.current.zip'
  end
  
  def self.gb_size
    file = Rails.root.join('public', self.public_path)
    if File.file? file
      "(Size: #{(File.size(file).to_f / (2**30)).round(2)})"
    else
      ""
    end
  end
end
