# frozen_string_literal: true

require 'zip'
require_relative 'data_zipper_service/generate_user_phenotype_csv'
require_relative 'data_zipper_service/zip_user_picture_phenotypes'

class DataZipperService
  CSV_OPTIONS = { col_sep: ';' }.freeze
  PUBLIC_PATH = '/data/zip/opensnp_datadump.current.zip'
  DEFAULT_OUTPUT_DIR = Rails.root.join('public', 'data', 'zip').freeze

  attr_reader :time, :time_str, :zip_public_path, :zip_tmp_path, :tmp_dir,
              :link_path, :output_dir, :logger

  def initialize(output_dir: DEFAULT_OUTPUT_DIR, logger: Logger.new(STDOUT))
    @output_dir = output_dir
    @time = Time.now.utc
    @time_str = time.strftime('%Y%m%d%H%M')
    @tmp_dir = Rails.root.join('tmp', "opensnp_datadump.#{time_str}")
    zip_file_name = "opensnp_datadump.#{time_str}.zip"
    @zip_public_path = @output_dir.join(zip_file_name)
    @zip_tmp_path = Rails.root.join('tmp', zip_file_name)
    @link_path = @output_dir.join('opensnp_datadump.current.zip')
    @logger = logger
  end

  def call
    # only create a new file if in the current minute none has been created yet
    if Dir.exist?(tmp_dir)
      logger.error("Directory #{tmp_dir} already exists. Exiting...")
      return false
    end

    begin
      logger.info("Creating temp dir: #{tmp_dir}")
      Dir.mkdir(tmp_dir)
      logger.info("Creating zipfile: #{zip_tmp_path}")
      Zip::File.open(zip_tmp_path, Zip::File::CREATE) do |zipfile|
        zip_user_phenotypes(zipfile)
        zip_user_picture_phenotypes(zipfile)
        zip_readme(zipfile)
        zip_genotype_files(zipfile)
      end

      # move from local storage to network storage
      logger.info("Copying #{zip_tmp_path} to #{zip_public_path}")
      FileUtils.cp(zip_tmp_path, zip_public_path)
      logger.info("Deleting #{zip_tmp_path}")
      FileUtils.rm(zip_tmp_path)
      logger.info("Creating symlink #{link_path} to #{zip_public_path}")
      FileUtils.ln_sf(zip_public_path, link_path)

      # everything went OK, now delete old zips
      delete_old_zips
    ensure
      logger.info("Deleting #{tmp_dir}")
      FileUtils.rm_rf(tmp_dir)
    end
  end

  def self.public_path
    PUBLIC_PATH
  end

  private

  # Create a CSV with a row for each genotype, with user data and phenotypes as
  # columns.
  def zip_user_phenotypes(zipfile)
    logger.info('Zipping user phenotypes')
    zipfile.get_output_stream("phenotypes_#{time_str}.csv") do |f|
      GenerateUserPhenotypeCsv.new.call.each do |row|
        f.write(row)
      end
    end
  end

  # make a CSV describing all of them - which filename is for which user's phenotype
  def zip_user_picture_phenotypes(zipfile)
    logger.info('Zipping user picture phenotypes')
    ZipUserPicturePhenotypes.new(zipfile, tmp_dir, time_str).call
  end

  def zip_readme(zipfile)
    logger.info('Zipping readme')
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
    logger.info('Zipping genotype files')
    ZipGenotypeFiles.new(zipfile).call
  end

  def delete_old_zips
    forbidden_files = [link_path, zip_public_path].map(&:to_s)
    Dir[output_dir.join('opensnp_datadump.*.zip')].each do |f|
      next if forbidden_files.include?(f)
      logger.info("Deleting #{f}")
      File.delete(f)
    end
  end
end
