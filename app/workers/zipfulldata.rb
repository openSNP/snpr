
# frozen_string_literal: true
require 'csv'
require 'zip'


class Zipfulldata
  include Sidekiq::Worker
  sidekiq_options queue: :zipfulldata, retry: 0, unique: true, dead: false
  # can't do retry => false.
  # Note with retry disabled, Sidekiq will not track or save any error data for the worker's jobs.
  # dead => false means don't send dead job to the dead queue, we don't care about that

  DEFAULT_OUTPUT_DIR = Rails.root.join('public', 'data', 'zip')

  attr_reader :time, :time_str, :csv_options, :dump_file_name, :zip_public_path,
              :zip_fs_path, :tmp_dir, :link_path, :output_dir

  def perform
    logger.info('job started')
    run
    logger.info('job done')
  end

  def initialize(output_dir: nil)
    @output_dir = output_dir || DEFAULT_OUTPUT_DIR
    @time = Time.now.utc
    @time_str = time.strftime("%Y%m%d%H%M")
    @csv_options = { col_sep: ';' }
    @dump_file_name = "opensnp_datadump.#{time_str}"
    @zip_public_path = @output_dir.join("#{dump_file_name}.zip")
    @zip_fs_path = "/tmp/#{dump_file_name}.zip"
    @tmp_dir = "#{Rails.root}/tmp/#{dump_file_name}"
    @link_path = @output_dir.join('opensnp_datadump.current.zip')
  end

  def run
    genotypes = Genotype.includes(user: :user_phenotypes)
    logger.info("Got #{genotypes.length} genotypes")

    # only create a new file if in the current minute none has been created yet
    if Dir.exists?(tmp_dir)
      logger.info("Directory #{tmp_dir} already exists. Exiting...")
      return false
    end

    begin
      logger.info("Making tmpdir #{tmp_dir}")
      Dir.mkdir(tmp_dir)
      logger.info("Starting zipfile #{zip_fs_path}")
      Zip::File.open(zip_fs_path, Zip::File::CREATE) do |zipfile|
        create_user_csv(genotypes, zipfile)
        list_of_pics = create_picture_phenotype_csv(zipfile)
        create_picture_zip(list_of_pics, zipfile)
        create_readme(zipfile)
        zip_genotype_files(genotypes, zipfile)
      end
      # move from local storage to network storage
      FileUtils.cp(@zip_fs_path, zip_public_path)
      FileUtils.rm(@zip_fs_path)
      logger.info('created zip-file')

      FileUtils.ln_sf(zip_public_path, link_path)

      # everything went OK, now delete old zips
      delete_old_zips
    ensure
      FileUtils.rm_rf(tmp_dir)
    end
    true
  end

  # Create a CSV with a row for each genotype, with user data and phenotypes as
  # columns.
  def create_user_csv(genotypes, zipfile)
    phenotypes = Phenotype.select(:characteristic).order(:id)
    characteristics = phenotypes.pluck(:characteristic)

    csv_file_name = "#{tmp_dir}/dump#{time_str}.csv"
    csv_head = %w(user_id genotype_filename date_of_birth chrom_sex openhumans_name)
    csv_head += characteristics

    CSV.open(csv_file_name, "w", csv_options) do |csv|
      csv << csv_head

      # Build a pivot table with characteristics and user IDs as dimensions and
      # variations as values, join with genotypes so the users'
      # characteristic-variation pairs show up as attributes of each respective
      # Genotype.
      Genotype
        .select(
          'genotypes.*',
          'users.yearofbirth AS user_yob',
          'users.sex AS user_sex',
          'open_humans_profiles.open_humans_user_id AS oh_user_id',
          'ct_variations.*',
          'genotypes.user_id'
        )
        .joins(:user)
        .joins('LEFT JOIN open_humans_profiles ON open_humans_profiles.user_id = users.id')
        .joins(<<-SQL)
          LEFT JOIN (
            SELECT * FROM CROSSTAB(
             'SELECT user_phenotypes.user_id, phenotypes.characteristic, user_phenotypes.variation
              FROM user_phenotypes JOIN phenotypes ON user_phenotypes.phenotype_id = phenotypes.id
              ORDER BY 1, phenotypes.id',
             '#{phenotypes.to_sql}'
            ) AS ct_variations(
              #{(['user_id integer'] + characteristics.map { |c| "\"#{c}\" text" }).join(', ')}
            )
          ) ct_variations
          ON ct_variations.user_id = genotypes.user_id
        SQL
        .order('genotypes.id')
        .each do |genotype|
          csv << [
            genotype.user_id,
            genotype.fs_filename,
            genotype.user_yob,
            genotype.user_sex,
            genotype.oh_user_id || '-'
          ] + characteristics.map { |c| genotype[c] || '-' }
        end
    end
    logger.info('created user csv')
    zipfile.add("phenotypes_#{time_str}.csv", csv_file_name)
  end

  # make a CSV describing all of them - which filename is for which user's phenotype
  def create_picture_phenotype_csv(zipfile)
    file_name = "#{tmp_dir}/picture_dump#{time_str}.csv"
    logger.info("Writing picture-CSV to #{file_name}")

    list_of_pics = [] # need this for the zip-file-later

    picture_phenotypes = PicturePhenotype.all
    csv_head = %w(user_id date_of_birth chrom_sex)
    csv_head.concat(picture_phenotypes.map(&:characteristic))

    CSV.open(file_name, "w", csv_options) do |csv|

      csv << csv_head

      # create lines in csv-file for each user who has uploaded his data

      User.includes(:user_picture_phenotypes).order(:id).each do |u|
        logger.info("Looking at user #{u.id}")
        row = [u.id, u.yearofbirth, u.sex]
        picture_phenotypes.each do |pp|

          # copy the picture with name to +user_id+_+pic_phenotype_id+.png
          # logger.info("Looking for this picture #{pp.id}")
          picture = pp.user_picture_phenotypes.where(user_id: u.id).first
          # does this user have this pic?
          if picture.present? && picture.phenotype_picture.present?
            picture_path = picture.phenotype_picture.path
            basename = picture_path.split("/")[-1]
            filetype = basename.split(".")[-1]
            logger.info("FOUND file #{picture_path}, basename is #{basename}")

            list_of_pics << picture
            row << "#{picture.id}.#{filetype}"
          else
            row << '-'
          end
        end
        logger.info('Putting a line into CSV')
        csv << row
      end
    end
    logger.info('created picture handle csv-file')
    zipfile.add("picture_phenotypes_#{time_str}.csv", file_name)
    list_of_pics
  end

  def create_picture_zip(list_of_pics, zipfile)
    pic_zipname = output_dir.join("opensnp_picturedump.#{time_str}.zip")
    Zip::File.open(pic_zipname, Zip::File::CREATE) do |z|
      list_of_pics.each do |tmp|
        begin
          file_name = tmp.phenotype_picture.path
          basename = file_name.split("/")[-1]
          filetype = basename.split(".")[-1]
          logger.info("Adding file to zip named #{tmp.id.to_s + "." + filetype}")
          z.add(tmp.id.to_s+"."+filetype, file_name)
          logger.info("Added #{tmp.id.to_s + "." + filetype}")
        rescue => e
          logger.info("create_picture_zip: #{e.class}: #{e.message}")
        end
      end
    end
    zipfile.add("picture_phenotypes_#{time_str}_all_pics.zip", pic_zipname)
    logger.info('created picture zip file')
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
      next unless File.exist?(gen_file.genotype.path)

      yob = gen_file.user.yearofbirth
      sex = gen_file.user.sex
      to_zip_file = gen_file.genotype.path

      if yob == "rather not say"
          yob = "unknown"
      end
      if sex == "rather not say"
          sex = "unknown"
      end

      zipfile.add(
        "user#{gen_file.user_id}_file#{gen_file.id}_yearofbirth_#{yob}_" \
          "sex_#{sex}.#{gen_file.filetype}.txt",
        to_zip_file
      )
    end
  end

  def delete_old_zips
    forbidden_files = [link_path, output_dir.join("#{dump_file_name}.zip")].map(&:to_s)
    Dir[output_dir.join('opensnp_datadump.*.zip')].each do |f|
      File.delete(f) unless forbidden_files.include?(f)
    end
  end

  def self.public_path
    '/data/zip/opensnp_datadump.current.zip'
  end

  def self.gb_size
    path = DEFAULT_OUTPUT_DIR.join('opensnp_datadump.current.zip')
    if File.exist?(path) && File.exist?(File.readlink(path))
      "(Size: #{(File.size(File.readlink(path)).to_f / (2**30)).round(2)})"
    else
      ""
    end
  end
end
