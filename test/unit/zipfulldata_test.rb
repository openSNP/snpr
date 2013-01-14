require_relative '../test_helper'

class ZipfulldataTest < ActiveSupport::TestCase
  context "Zipfulldata" do
    setup do
      @user = FactoryGirl.create(:user)
      @phenotype = FactoryGirl.create(:phenotype, characteristic: "jump height")
      @user_phenotype = FactoryGirl.create(:user_phenotype, user_id: @user.id,
        phenotype_id: @phenotype.id, variation: "1km")
      @genotype = FactoryGirl.create(:genotype, user_id: @user.id)
      FileUtils.cp("#{Rails.root}/test/data/23andMe_test.csv",
        "#{Rails.root}/public/data/#{@user.id}.23andme.#{@genotype.id}")
      @job = Zipfulldata.new
      @tmp_dir = @job.instance_variable_get(:@tmp_dir) + '_test_' +
        Digest::SHA1.hexdigest("#{Time.now.to_i}#{rand}")
      @job.instance_variable_set(:@tmp_dir, @tmp_dir)
      Dir.mkdir(@tmp_dir)
    end

    should "create user csv" do
      @job.create_user_csv([@genotype])
      csv = CSV.read("#{@tmp_dir}/dump#{@job.time_str}.csv", @job.csv_options)
      exp_header = ["user_id", "date_of_birth", "chrom_sex",
                    @phenotype.characteristic]
      exp_row = [@user.id.to_s, @user.yearofbirth, @user.sex,
                 @user.user_phenotypes.first.variation]
      assert_equal [exp_header, exp_row], csv
    end

    should "create fitbit csv" do
      fp = FactoryGirl.create(:fitbit_profile, user: @user)
      @job.create_fitbit_csv
      csv = CSV.read(
        "#{@tmp_dir}/dump_user#{@user.id}_fitbit_data_#{@job.time_str}.csv",
        @job.csv_options)
      exp_header = ["date", "steps", "floors", "weight", "bmi",
                    "minutes asleep", "minutes awake", "times awaken",
                    "minutes until fell asleep"]
      exp_row = [fp.fitbit_activities.first.date_logged,
                 fp.fitbit_activities.first.steps,
                 fp.fitbit_activities.first.floors,
                 fp.fitbit_bodies.first.weight,
                 fp.fitbit_bodies.first.bmi,
                 fp.fitbit_sleeps.first.minutes_asleep,
                 fp.fitbit_sleeps.first.minutes_awake,
                 fp.fitbit_sleeps.first.number_awakenings,
                 fp.fitbit_sleeps.first.minutes_to_sleep]
      assert_equal [exp_header, exp_row], csv
    end



    should "zip the full data" do
      time = Time.now
      time_str = time.utc.strftime("%Y%m%d%H%M")
      Time.stubs(:now).returns time

      old_entries = Dir.entries("#{Rails.root}/public/data/zip")
      # should have two new files - picture-dump, genotyping-dump
      assert_difference('Dir.entries("#{Rails.root}/public/data/zip").size', +2) do
        Zipfulldata.perform 'foo@example.org'
      end

      created_zip =
          (Dir.entries("#{Rails.root}/public/data/zip").map{ |item| if item.include? "data"; item; end}.compact - old_entries).first
      # above is the weirdest way to get only the zips containing "data"

      assert_match "opensnp_datadump.#{time_str}.zip", created_zip

      file_count = 0
      Zip::ZipFile.foreach("#{Rails.root}/public/data/zip/#{created_zip}") do |file|
        file_count += 1
        file.get_input_stream do |content|
          case file.to_s
          when 'readme.txt' then
            assert_match "This archive was generated on #{time.to_s.gsub(":","_")} UTC. " <<
              "It contains 1 phenotypes, 1 genotypes and 0 picture phenotypes.\nThanks for using openSNP!\n", content.read
          when /23andme.txt\Z/ then
            assert_equal File.read("#{Rails.root}/test/data/23andMe_test.csv"),
              content.read
          when "phenotypes_#{time_str}.csv" then
            assert_equal \
              "user_id;date_of_birth;chrom_sex;jump height\n" <<
              "#{@user.id};1970;yes please;1km\n", content.read
          when "picture_phenotypes_#{time_str}.csv" then
              next # TODO: put proper test here
          when "picture_phenotypes_#{time_str}_all_pics.zip" then
              next # TODO: put proper test here
          else
            raise "unknown file #{file} in zip"
          end
        end
      end
      assert_equal 5, file_count
      File.delete("#{Rails.root}/public/data/zip/#{created_zip}")
    end

    should "not zip the full data if zip already exists" do
      time = Time.now
      time_str = time.utc.strftime("%Y%m%d%H%M")
      Time.stubs(:now).returns time
      file = "#{Rails.root}/public/data/zip/opensnp_datadump.#{time_str}.zip"
      File.open(file, 'w').close
      old_stat = File.stat(file)

      Phenotype.expects(:find_each).never
      assert_no_difference 'Dir.entries("#{Rails.root}/public/data/zip").size' do
        Zipfulldata.perform 'foo@example.org'
      end

      assert_equal 0, File.stat(file) <=> old_stat
      assert_nil File.size?(file)
      File.delete(file)
    end
  end
end
