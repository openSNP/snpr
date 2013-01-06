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
