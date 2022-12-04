describe Zipfulldata do
  subject(:worker) { described_class.new(output_dir: output_dir) }

  let(:output_dir) { Rails.root.join('tmp', 'test', 'zipfulldata') }
  let(:symlink) { output_dir.join('opensnp_datadump.current.zip') }
  let(:picture_zip) { Dir[output_dir.join('opensnp_picturedump.*.zip')].last }

  before do
    FileUtils.mkdir_p(output_dir)
  end

  after do
    FileUtils.rm_rf(output_dir)
  end

  it 'creates a new dump file and symlink' do
    worker.perform

    expect(File.symlink?(symlink)).to be(true)
    expect(File.exist?(File.readlink(symlink)))
  end

  it 'adds a README' do
    worker.perform

    Zip::File.open(symlink) do |zip|
      readme = zip.read('readme.txt')
      expect(readme).to include('This archive was generated')
    end
  end

  context 'when deleting files' do
    let(:unrelated_file_path) { output_dir.join('do_not_delete_me.zip') }
    let(:old_dump_file_path) { output_dir.join('opensnp_datadump.197001010000.zip') }

    before do
      [unrelated_file_path, old_dump_file_path].each do |path|
        FileUtils.touch(path)
      end
    end

    it 'deletes old dump files' do
      worker.perform

      expect(File.exist?(old_dump_file_path)).to be(false)
    end

    it 'does not delete unrelated files' do
      worker.perform

      expect(File.exist?(unrelated_file_path)).to be(true)
    end

    after do
      [unrelated_file_path, old_dump_file_path].each do |path|
        FileUtils.rm(path) if File.exist?(path)
      end
    end
  end

  context 'for existing data' do
    let!(:user_1) { create(:user, yearofbirth: 1970, sex: 'why not') }
    let!(:genotype_1) { create(:genotype, user: user_1) }
    let!(:open_humans_profile) do
      create(:open_humans_profile, user: user_1, open_humans_user_id: 'oh-user')
    end

    let!(:user_2) { create(:user, yearofbirth: 1994, sex: 'no') }
    let!(:genotype_2) { create(:genotype, user: user_2) }

    let!(:user_3) { create(:user) }

    let!(:phenotype_1) { create(:phenotype, characteristic: 'number of eyes') }
    let!(:phenotype_2) { create(:phenotype, characteristic: 'length of tongue') }

    let!(:user_phenotype_1) do
      create(:user_phenotype, phenotype: phenotype_1, user: user_1, variation: '5')
    end
    let!(:user_phenotype_2) do
      create(:user_phenotype, phenotype: phenotype_1, user: user_2, variation: '1')
    end
    let!(:user_phenotype_3) do
      create(:user_phenotype, phenotype: phenotype_2, user: user_1, variation: '59 cm')
    end

    it 'adds a CSV with user data to the zip file' do
      worker.perform

      Zip::File.open(symlink) do |zip|
        phenotypes_csv = zip.glob('phenotypes_*.csv').first
        expect(CSV.parse(zip.read(phenotypes_csv.name), col_sep: ';')).to eq(
          [
            [
              'user_id',
              'genotype_filename',
              'date_of_birth',
              'chrom_sex',
              'openhumans_name',
              'number of eyes',
              'length of tongue'
            ],
            [
              user_1.id.to_s,
              genotype_1.fs_filename,
              '1970',
              'why not',
              'oh-user',
              '5',
              '59 cm'
            ],
            [
              user_2.id.to_s,
              genotype_2.fs_filename,
              '1994',
              'no',
              '-',
              '1',
              '-'
            ]
          ]
        )
      end
    end

    it 'adds genotype files to the ZIP file' do
      worker.perform

      Zip::File.open(symlink) do |zip|
        expect(zip.glob('user*.txt').map(&:name)).to eq(
          [
            "user#{user_1.id}_file#{genotype_1.id}_yearofbirth_1970_sex_why not.23andme.txt",
            "user#{user_2.id}_file#{genotype_2.id}_yearofbirth_1994_sex_no.23andme.txt"
          ]
        )

        expect(zip.read(zip.glob('user*.txt').first.name))
          .to eq("assorted genotype data\n")
      end
    end
  end

  context 'for images' do
    let!(:user_1) { create(:user, yearofbirth: 1970, sex: 'why not') }
    let!(:genotype_1) { create(:genotype, user: user_1) }
    let!(:open_humans_profile) do
      create(:open_humans_profile, user: user_1, open_humans_user_id: 'oh-user')
    end

    let!(:user_2) { create(:user, yearofbirth: 1994, sex: 'no') }
    let!(:genotype_2) { create(:genotype, user: user_2) }

    let!(:user_3) { create(:user, yearofbirth: 1922, sex: 'male') }

    let!(:picture_phenotype_1) do
      create(:picture_phenotype, characteristic: 'number of eyes')
    end
    let!(:picture_phenotype_2) do
      create(:picture_phenotype, characteristic: 'length of tongue')
    end

    let!(:user_picture_phenotype_1) do
      create(
        :user_picture_phenotype,
        picture_phenotype: picture_phenotype_1,
        user: user_1,
        variation: '5'
      )
    end
    let!(:user_picture_phenotype_2) do
      create(
        :user_picture_phenotype,
        picture_phenotype: picture_phenotype_1,
        user: user_2,
        variation: '1'
      )
    end
    let!(:user_picture_phenotype_3) do
      create(
        :user_picture_phenotype,
        picture_phenotype: picture_phenotype_2,
        user: user_1,
        variation: '59 cm'
      )
    end

    # There needs to be at least one Phenotype for the CROSSTAB query to work.
    let!(:phenotype) { create(:phenotype) }

    it 'adds a CSV with image data to the zip file' do
      worker.perform

      Zip::File.open(symlink) do |zip|
        picture_phenotypes_csv = zip.glob('picture_phenotypes_*.csv').first
        expect(CSV.parse(zip.read(picture_phenotypes_csv.name), col_sep: ';')).to eq(
          [
            [
              'user_id',
              'date_of_birth',
              'chrom_sex',
              'number of eyes',
              'length of tongue'
            ],
            [
              user_1.id.to_s,
              '1970',
              'why not',
              "#{user_picture_phenotype_1.id}.png",
              "#{user_picture_phenotype_3.id}.png"
            ],
            [
              user_2.id.to_s,
              '1994',
              'no',
              "#{user_picture_phenotype_2.id}.png",
              '-'
            ],
            # TODO: Should users without picture phenotypes show up?
            [
              user_3.id.to_s,
              '1922',
              'male',
              '-',
              '-'
            ]
          ]
        )
      end
    end

    it 'creates a ZIP file with phenotype images to the ZIP file' do
      worker.perform

      Zip::File.open(symlink) do |zip|
        zip.extract(
          zip.glob('picture_phenotypes_*_all_pics.zip').last.name,
          output_dir.join('picture_phenotypes_all_pics.zip')
        )
      end

      Zip::File.open(output_dir.join('picture_phenotypes_all_pics.zip')) do |zip|
        expect(zip.glob('*').map(&:name).sort).to eq(
          [
            user_picture_phenotype_1,
            user_picture_phenotype_2,
            user_picture_phenotype_3
          ].map(&:id).sort.map { |id| "#{id}.png" }
        )
      end
    end
  end

  describe '.public_path' do
    it 'returns the public path of the zip file' do
      expect(described_class.public_path)
        .to eq('/data/zip/opensnp_datadump.current.zip')
    end
  end

  describe '.gb_size' do
    before do
      stub_const("#{described_class}::DEFAULT_OUTPUT_DIR", output_dir)
    end

    it 'returns the size of the zip file' do
      worker.perform

      expect(described_class.gb_size).to eq('(Size: 0.0)')
    end
  end
end
