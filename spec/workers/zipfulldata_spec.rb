require 'spec_helper'

describe Zipfulldata do
  let(:phenotype) { create(:phenotype, characteristic: "jump height") }
  let(:user_phenotype) do
    create(:user_phenotype, phenotype_id: phenotype.id, variation: "1km", user_id: nil)
  end
  let(:user) { create(:user, user_phenotypes: [user_phenotype]) }
  let(:genotype) do
    create(:genotype, user_id: user.id,
           genotype: File.open("#{Rails.root}/test/data/23andMe_test.csv"))
  end
  let(:job) { Zipfulldata.new }
  let(:csv_options) { { col_sep: ';' } }
  let(:zipfile) { double('zipfile') }

  before do
    allow(Sidekiq::Client).to receive(:enqueue).with(Preparsing, instance_of(Fixnum))
    tmp_dir = job.instance_variable_get(:@tmp_dir) + '_test_' +
      Digest::SHA1.hexdigest("#{Time.now.to_i}#{rand}")
    job.instance_variable_set(:@tmp_dir, tmp_dir)
    Dir.mkdir(tmp_dir)
    genotype
  end

  after do
    link = Rails.root.join("public/data/zip/opensnp_datadump.current.zip")
    FileUtils.rm(link) if File.exist?(link)
  end

  it "creates user CSVs" do
    user2 = create(:user)
    genotype2 = create(:genotype, user_id: user2.id)
    expect(zipfile).to receive(:add).
      with("phenotypes_#{job.time_str}.csv",
           "#{job.tmp_dir}/dump#{job.time_str}.csv")
    job.create_user_csv([genotype, genotype2], zipfile)
    csv = CSV.read("#{job.tmp_dir}/dump#{job.time_str}.csv", job.csv_options)
    exp_header = ["user_id", "date_of_birth", "chrom_sex",
                  phenotype.characteristic]
    exp_row1 = [user.id.to_s, user.yearofbirth, user.sex,
                user.user_phenotypes.first.variation]
    exp_row2 = [user2.id.to_s, user2.yearofbirth, user2.sex, '-']
    expect(user.user_phenotypes.first.phenotype).to eq(phenotype)
    expect(csv).to eq([exp_header, exp_row1, exp_row2])
  end

  it "creates fitbit CSVs" do
    file_name =
      "#{job.tmp_dir}/dump_user#{user.id}_fitbit_data_#{job.time_str}.csv"
    fp = create(:fitbit_profile, user: user)
    expect(zipfile).to receive(:add).
      with("user#{fp.user.id}_fitbit_data_#{job.time_str}.csv", file_name)
    job.create_fitbit_csv(zipfile)
    csv = CSV.read(file_name, job.csv_options)
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
    expect(csv).to eq([exp_header, exp_row])
  end

  it "creates picture phenotype CSVs" do
    user2 = create(:user)
    pp = create(:picture_phenotype)
    upp = create(:user_picture_phenotype, picture_phenotype: pp,
                             user: user)
    pic = double('picture')
    expect(pic).to receive(:path).and_return("#{Rails.root}/foo/bar.png")
    allow_any_instance_of(UserPicturePhenotype).to receive(:phenotype_picture).
      and_return(pic)
    expect(zipfile).to receive(:add).
      with("picture_phenotypes_#{job.time_str}.csv",
           "#{job.tmp_dir}/picture_dump#{job.time_str}.csv")
    job.create_picture_phenotype_csv(zipfile)
    csv = CSV.read("#{job.tmp_dir}/picture_dump#{job.time_str}.csv", csv_options)
    expect(csv).to eq(
      [["user_id", "date_of_birth", "chrom_sex", "Eye color"],
       [user.id.to_s, user.yearofbirth, user.sex, "#{upp.id}.png"],
       [user2.id.to_s, user2.yearofbirth, user2.sex, '-']]
    )
  end

  it "creates a readme file" do
    expect(Phenotype).to receive(:count).and_return(42)
    expect(Genotype).to receive(:count).and_return(23)
    expect(PicturePhenotype).to receive(:count).and_return(5)
    expect(zipfile).to receive(:add).
      with("readme.txt", "#{job.tmp_dir}/dump#{job.time_str}.txt")
    job.create_readme(zipfile)
    readme = File.read("#{job.tmp_dir}/dump#{job.time_str}.txt")
    exp_text = <<-TXT
This archive was generated on #{job.time.ctime} UTC. It contains 42 phenotypes, 23 genotypes and 5 picture phenotypes.

Thanks for using openSNP!
    TXT
  end

  it "zips genotype files" do
    expect(zipfile).to receive(:add).with(
      "user#{user.id}_file#{genotype.id}_yearofbirth_#{user.yearofbirth}" +
      "_sex_#{user.sex}.#{genotype.filetype}.txt",
      "#{Rails.root}/public/data/#{genotype.fs_filename}")
    job.zip_genotype_files([genotype], zipfile)
  end

  it "runs the job" do
    upp = double('user_picture_phenotype')
    expect(Dir).to receive(:exists?).with(job.tmp_dir).and_return(false)
    expect(Dir).to receive(:mkdir).with(job.tmp_dir)
    expect(Zip::File).to receive(:open).with(job.zip_fs_path, Zip::File::CREATE).
      and_yield(zipfile)
    expect(job).to receive(:create_user_csv).with([genotype], zipfile)
    expect(job).to receive(:create_fitbit_csv).with(zipfile)
    expect(job).to receive(:create_picture_phenotype_csv).with(zipfile).and_return([upp])
    expect(job).to receive(:create_picture_zip).with([upp], zipfile)
    expect(job).to receive(:create_readme).with(zipfile)
    expect(job).to receive(:zip_genotype_files).with([genotype], zipfile)
    expect(FileUtils).to receive(:chmod).
      with(0644, "#{Rails.root}/public/data/zip/#{job.dump_file_name}.zip")
    expect(FileUtils).to receive(:ln_sf).with(
      Rails.root.join("public/data/zip/#{job.dump_file_name}.zip"),
      Rails.root.join("public/data/zip/opensnp_datadump.current.zip"))
    expect(FileUtils).to receive(:rm_rf).with(job.tmp_dir)
    expect(job.run).to be(true)
  end
end
