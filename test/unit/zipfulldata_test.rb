require_relative '../test_helper'

class ZipfulldataTest < ActiveSupport::TestCase
  context "Zipfulldata" do
    setup do
      stub_solr
      @user = FactoryGirl.create(:user)
      @phenotype = FactoryGirl.create(:phenotype, characteristic: "jump height")
      @user_phenotype = FactoryGirl.create(:user_phenotype, user_id: @user.id,
        phenotype_id: @phenotype.id, variation: "1km")
      Sidekiq::Client.stubs(:enqueue).with(Preparsing, instance_of(Fixnum))
      @genotype = FactoryGirl.create(:genotype, user_id: @user.id)
      FileUtils.cp("#{Rails.root}/test/data/23andMe_test.csv",
        "#{Rails.root}/public/data/#{@user.id}.23andme.#{@genotype.id}")
      @job = Zipfulldata.new
      tmp_dir = @job.instance_variable_get(:@tmp_dir) + '_test_' +
        Digest::SHA1.hexdigest("#{Time.now.to_i}#{rand}")
      @job.instance_variable_set(:@tmp_dir, tmp_dir)
      Dir.mkdir(tmp_dir)
      @csv_options = { col_sep: ';' }
      @zipfile = mock('zipfile')
    end

    should "create user csv" do
      user2 = FactoryGirl.create(:user)
      genotype2 = FactoryGirl.create(:genotype, user_id: user2.id)
      @zipfile.expects(:add).with("phenotypes_#{@job.time_str}.csv",
                                  "#{@job.tmp_dir}/dump#{@job.time_str}.csv")
      @job.create_user_csv([@genotype, genotype2], @zipfile)
      csv = CSV.read("#{@job.tmp_dir}/dump#{@job.time_str}.csv", @job.csv_options)
      exp_header = ["user_id", "date_of_birth", "chrom_sex",
                    @phenotype.characteristic]
      exp_row1 = [@user.id.to_s, @user.yearofbirth, @user.sex,
                  @user.user_phenotypes.first.variation]
      exp_row2 = [user2.id.to_s, user2.yearofbirth, user2.sex, '-']
      assert_equal @phenotype, @user.user_phenotypes.first.phenotype
      assert_equal [exp_header, exp_row1, exp_row2], csv
    end

    should "create fitbit csv" do
      file_name =
        "#{@job.tmp_dir}/dump_user#{@user.id}_fitbit_data_#{@job.time_str}.csv"
      fp = FactoryGirl.create(:fitbit_profile, user: @user)
      @zipfile.expects(:add).
        with("user#{fp.user.id}_fitbit_data_#{@job.time_str}.csv", file_name)
      @job.create_fitbit_csv(@zipfile)
      csv = CSV.read(file_name, @job.csv_options)
      exp_header = ["date", "steps", "floors", "weight", "bmi",
                    "minutes asleep", "minutes awake", "times awaken",
                    "minutes until fell asleep"]
      exp_row = [fp.fitbit_activities.first.date_logged.to_s,
                 fp.fitbit_activities.first.steps.to_s,
                 fp.fitbit_activities.first.floors.to_s,
                 fp.fitbit_bodies.first.weight.to_s,
                 fp.fitbit_bodies.first.bmi.to_s,
                 fp.fitbit_sleeps.first.minutes_asleep.to_s,
                 fp.fitbit_sleeps.first.minutes_awake.to_s,
                 fp.fitbit_sleeps.first.number_awakenings.to_s,
                 fp.fitbit_sleeps.first.minutes_to_sleep.to_s]
      assert_equal [exp_header, exp_row], csv
    end

    should "create picture phenotype csv" do
      user2 = FactoryGirl.create(:user)
      pp = FactoryGirl.create(:picture_phenotype)
      upp = FactoryGirl.create(:user_picture_phenotype, picture_phenotype: pp,
                               user: @user)
      pic = mock('picture')
      pic.expects(:path).returns("#{Rails.root}/foo/bar.png")
      UserPicturePhenotype.any_instance.stubs(:phenotype_picture).returns(pic)
      @zipfile.expects(:add).with("picture_phenotypes_#{@job.time_str}.csv",
          "#{@job.tmp_dir}/picture_dump#{@job.time_str}.csv")
      @job.create_picture_phenotype_csv(@zipfile)
      csv = CSV.read("#{@job.tmp_dir}/picture_dump#{@job.time_str}.csv", @csv_options)
      assert_equal(
        [["user_id", "date_of_birth", "chrom_sex", "Eye color"],
         [@user.id.to_s, @user.yearofbirth, @user.sex, "#{upp.id}.png"],
         [user2.id.to_s, user2.yearofbirth, user2.sex, '-']],
        csv)
    end

    should "create a readme file" do
      Phenotype.expects(:count).returns(42)
      Genotype.expects(:count).returns(23)
      PicturePhenotype.expects(:count).returns(5)
      @zipfile.expects(:add).
        with("readme.txt", "#{@job.tmp_dir}/dump#{@job.time_str}.txt")
      @job.create_readme(@zipfile)
      readme = File.read("#{@job.tmp_dir}/dump#{@job.time_str}.txt")
      exp_text = <<-TXT
This archive was generated on #{@job.time.ctime} UTC. It contains 42 phenotypes, 23 genotypes and 5 picture phenotypes.

Thanks for using openSNP!
TXT
    end

    should "zip genotype files" do
      @zipfile.expects(:add).with(
        "user#{@user.id}_file#{@genotype.id}_yearofbirth_#{@user.yearofbirth}" +
          "_sex_#{@user.sex}.#{@genotype.filetype}.txt",
        "#{Rails.root}/public/data/#{@genotype.fs_filename}")
      @job.zip_genotype_files([@genotype], @zipfile)
    end

    should "run the job" do
      upp = mock('user_picture_phenotype')
      Dir.expects(:exists?).with(@job.tmp_dir).returns(false)
      Dir.expects(:mkdir).with(@job.tmp_dir)
      Zip::File.expects(:open).with(@job.zip_fs_path, Zip::File::CREATE).
        yields(@zipfile)
      FileLink.any_instance.expects(:save)
      @job.expects(:create_user_csv).with([@genotype], @zipfile)
      @job.expects(:create_fitbit_csv).with(@zipfile)
      @job.expects(:create_picture_phenotype_csv).returns([upp], @zipfile)
      @job.expects(:create_picture_zip).with([upp], @zipfile)
      @job.expects(:create_readme).with(@zipfile)
      @job.expects(:zip_genotype_files).with([@genotype], @zipfile)
      FileUtils.expects(:chmod).
        with(0755, "#{Rails.root}/public/data/zip/#{@job.dump_file_name}.zip")
      mail = mock('mail')
      mail.expects(:deliver)
      UserMailer.expects(:dump).
        with("fubert@example.com", "/data/zip/#{@job.dump_file_name}.zip").
        returns(mail)
      FileUtils.expects(:rm_rf).with(@job.tmp_dir)
      assert @job.run("fubert@example.com")
    end
  end
end
