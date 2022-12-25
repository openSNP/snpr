# frozen_string_literal: true

RSpec.describe DataZipperService::ZipUserPicturePhenotypes do
  subject(:zip) do
    zipfile = Zip::File.open(Tempfile.new, Zip::File::CREATE)
    described_class.new(zipfile, tmp_dir, time_str).call
    zipfile.close
    Zip::File.open(zipfile.name)
  end

  let(:zipfile_write) { Zip::File.open(zipfile_path, Zip::File::CREATE) }
  let(:tempfile) { Tempfile.new }
  let(:zipfile_path) { tempfile.path }
  let(:tmp_dir) do
    Rails.root.join('tmp', 'test', 'data_zipper_service', 'zip_user_picture_phenotypes')
  end
  let(:time_str) { '123' }

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
      user: user_1
    )
  end
  let!(:user_picture_phenotype_2) do
    create(
      :user_picture_phenotype,
      picture_phenotype: picture_phenotype_1,
      user: user_2
    )
  end
  let!(:user_picture_phenotype_3) do
    create(
      :user_picture_phenotype,
      picture_phenotype: picture_phenotype_2,
      user: user_1
    )
  end

  # There needs to be at least one Phenotype for the CROSSTAB query to work.
  let!(:phenotype) { create(:phenotype) }

  before do
    FileUtils.mkdir_p(tmp_dir)
  end

  after do
    FileUtils.rm_rf(tmp_dir)
  end

  it 'adds a CSV with image data to the zip file' do
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

  it 'creates a ZIP file with phenotype images and adds it to the ZIP file' do
    zip.extract(
      zip.glob('picture_phenotypes_*_all_pics.zip').last.name,
      tmp_dir.join('picture_phenotypes_all_pics.zip')
    )

    Zip::File.open(tmp_dir.join('picture_phenotypes_all_pics.zip')) do |zip|
      expect(zip.glob('*').map(&:name).sort).to eq(
        [
          user_picture_phenotype_1,
          user_picture_phenotype_2,
          user_picture_phenotype_3
        ].map(&:id).sort.map { |id| "#{id}.png" }
      )
    end
  end

  context 'when a user picture phenotype is missing an actual image' do
    before do
      user_picture_phenotype_1.phenotype_picture = nil
      user_picture_phenotype_1.save!
    end

    it 'ignores them' do
      zip.extract(
        zip.glob('picture_phenotypes_*_all_pics.zip').last.name,
        tmp_dir.join('picture_phenotypes_all_pics.zip')
      )

      Zip::File.open(tmp_dir.join('picture_phenotypes_all_pics.zip')) do |zip|
        expect(zip.glob('*').map(&:name).sort).to eq(
          [
            user_picture_phenotype_2,
            user_picture_phenotype_3
          ].map(&:id).sort.map { |id| "#{id}.png" }
        )
      end
    end
  end
end
