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
  CSV_OPTIONS = { col_sep: ';' }.freeze

  attr_reader :time, :time_str, :zip_public_path, :zip_tmp_path, :tmp_dir,
              :link_path, :output_dir

  def initialize(output_dir: nil)
    @output_dir = output_dir || DEFAULT_OUTPUT_DIR
    @time = Time.now.utc
    @time_str = time.strftime("%Y%m%d%H%M")
    @tmp_dir = Rails.root.join('tmp', "opensnp_datadump.#{time_str}")
    zip_file_name = "opensnp_datadump.#{time_str}.zip"
    @zip_public_path = @output_dir.join(zip_file_name)
    @zip_tmp_path = Rails.root.join('tmp', zip_file_name)
    @link_path = @output_dir.join('opensnp_datadump.current.zip')
  end

  def perform
    logger.info('job started')

    # only create a new file if in the current minute none has been created yet
    if Dir.exists?(tmp_dir)
      logger.info("Directory #{tmp_dir} already exists. Exiting...")
      return false
    end

    begin
      logger.info("Making tmpdir #{tmp_dir}")
      Dir.mkdir(tmp_dir)
      logger.info("Starting zipfile #{zip_tmp_path}")
      Zip::File.open(zip_tmp_path, Zip::File::CREATE) do |zipfile|
        zip_user_phenotypes(zipfile)
        zip_user_picture_phenotypes(zipfile)
        create_readme(zipfile)
        zip_genotype_files(zipfile)
      end
      # move from local storage to network storage
      FileUtils.cp(zip_tmp_path, zip_public_path)
      FileUtils.rm(zip_tmp_path)
      logger.info('created zip-file')

      FileUtils.ln_sf(zip_public_path, link_path)

      # everything went OK, now delete old zips
      delete_old_zips
    ensure
      FileUtils.rm_rf(tmp_dir)
    end
    logger.info('job done')
    true
  end

  def self.public_path
    '/data/zip/opensnp_datadump.current.zip'
  end

  def self.gb_size
    path = DEFAULT_OUTPUT_DIR.join('opensnp_datadump.current.zip')
    if File.exist?(path) && File.exist?(File.readlink(path))
      "(Size: #{(File.size(File.readlink(path)).to_f / (2**30)).round(2)})"
    else
      ''
    end
  end

  private

  # Create a CSV with a row for each genotype, with user data and phenotypes as
  # columns.
  def zip_user_phenotypes(zipfile)
    phenotypes = Phenotype.select(:characteristic).order(:id)
    characteristics = phenotypes.pluck(:characteristic)

    # Build a pivot table with characteristics and user IDs as dimensions and
    # variations as values.
    csv = ApplicationRecord.copy_csv(<<-SQL)
      SELECT
        user_id,
        fs_filename AS genotype_filename,
        user_yob AS date_of_birth,
        user_sex AS chrom_sex,
        oh_user_name AS openhumans_name,
        #{characteristics.map { |c| "COALESCE(\"#{c}\", '-') AS \"#{c}\"" }.join(', ')}
      FROM CROSSTAB(
       'SELECT genotypes.user_id, -- vertical dimension, must be first
               genotypes.user_id || ''.'' || genotypes.filetype || ''.'' || genotypes.id,
               users.yearofbirth,
               users.sex,
               COALESCE(open_humans_profiles.open_humans_user_id, ''-''),
               phenotypes.characteristic, -- column headers, must be second to last
               user_phenotypes.variation -- values, must be last
        FROM genotypes
        JOIN users ON users.id = genotypes.user_id
        JOIN user_phenotypes ON user_phenotypes.user_id = genotypes.user_id
        JOIN phenotypes ON phenotypes.id = user_phenotypes.phenotype_id
        LEFT JOIN open_humans_profiles ON open_humans_profiles.user_id = users.id
        ORDER BY user_id',
       '#{phenotypes.to_sql}'
      ) AS ct_variations(
        user_id integer,
        fs_filename text,
        user_yob integer,
        user_sex text,
        oh_user_name text,
        #{characteristics.map { |c| "\"#{c}\" text" }.join(', ')}
      )
    SQL

    zipfile.get_output_stream("phenotypes_#{time_str}.csv") do |f|
      csv.each do |row|
        f.write(row)
      end
    end

    logger.info('created user csv')
  end

  # make a CSV describing all of them - which filename is for which user's phenotype
  def zip_user_picture_phenotypes(zipfile)
    csv_path = tmp_dir.join("picture_dump#{time_str}.csv")
    picture_phenotypes = PicturePhenotype.order(:id)
    csv_head = %w(user_id date_of_birth chrom_sex)
    csv_head.concat(picture_phenotypes.pluck(:characteristic))
    picture_zip = Zip::File.open(
      output_dir.join("opensnp_picturedump.#{time_str}.zip"),
      Zip::File::CREATE
    )

    user_picture_phenotypes_csv = CSV.generate(CSV_OPTIONS) do |csv|
      csv << csv_head

      User
        .order(:id)
        .includes(:user_picture_phenotypes)
        .find_each do |user|
          csv << build_user_picture_phenotype_row(user, picture_phenotypes, picture_zip)
        end
    end

    picture_zip.close

    zipfile.get_output_stream("picture_phenotypes_#{time_str}.csv") do |f|
      f.write(user_picture_phenotypes_csv)
    end
    zipfile.add("picture_phenotypes_#{time_str}_all_pics.zip", picture_zip.name)
  end

  def build_user_picture_phenotype_row(user, picture_phenotypes, picture_zip)
    user_picture_phenotypes = user
                              .user_picture_phenotypes
                              .index_by(&:picture_phenotype_id)

    [
      user.id,
      user.yearofbirth,
      user.sex
    ] + picture_phenotypes.map do |picture_phenotype|
      user_picture_phenotype = user_picture_phenotypes[picture_phenotype.id]
      if user_picture_phenotype
        extension = user_picture_phenotype
                    .phenotype_picture
                    .content_type
                    .split('/')
                    .last
        extension = 'jpg' if extension == 'jpeg'
        file_name = "#{user_picture_phenotype.id}.#{extension}"
        picture_zip.add(file_name, user_picture_phenotype.phenotype_picture.path)
        file_name
      else
        '-'
      end
    end
  end

  def create_readme(zipfile)
    # make a README containing time of zip - this way, users can compare with page-status
    # and see how old the data is
    zipfile.get_output_stream('readme.txt') do |f|
      f.write(
        I18n.t(
          'zipfulldata.readme',
          time: time.ctime,
          phenotype_count: Phenotype.count,
          genotype_count: Genotype.count,
          picture_count: PicturePhenotype.count
        )
      )
    end
  end

  def zip_genotype_files(zipfile)
    Genotype.find_each do |gen_file|
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
    forbidden_files = [link_path, zip_public_path].map(&:to_s)
    Dir[output_dir.join('opensnp_datadump.*.zip')].each do |f|
      File.delete(f) unless forbidden_files.include?(f)
    end
  end
end
