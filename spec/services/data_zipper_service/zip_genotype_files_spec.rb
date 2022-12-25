# frozen_string_literal: true

describe DataZipperService::ZipGenotypeFiles do
  subject(:zip) do
    zipfile = Zip::File.open(Tempfile.new, Zip::File::CREATE)
    described_class.new(zipfile).call
    zipfile.close
    Zip::File.open(zipfile.name)
  end

  let!(:user_1) { create(:user, yearofbirth: 1970, sex: 'why not') }
  let!(:genotype_1) { create(:genotype, user: user_1) }
  let!(:open_humans_profile) do
    create(:open_humans_profile, user: user_1, open_humans_user_id: 'oh-user')
  end

  let!(:user_2) { create(:user, yearofbirth: 1994, sex: 'no') }
  let!(:genotype_2) { create(:genotype, user: user_2) }

  let!(:user_3) { create(:user) }

  it 'zips genotype files' do
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
