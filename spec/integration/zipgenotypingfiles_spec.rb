RSpec.describe Zipgenotypingfiles do
  let!(:user) { create(:user) }
  let!(:phenotype) { create(:phenotype) }
  let!(:user_phenotype) { create(:user_phenotype, phenotype: phenotype, user: user) }
  let!(:genotype) do
    create(
      :genotype,
      user: user,
      genotype: File.open(Rails.root.join('spec', 'fixtures', 'files', 'empty'))
    )
  end
  let(:file_path) { "data/zip/#{phenotype.id}.#{Time.now.strftime('%d.%m.%Y_%H_%M')}.zip" }
  let(:fs_path) { Rails.root.join('public', file_path) }

  around { |example| Timecop.freeze(Time.new(2015, 4, 6, 10, 21), &example) }

  after { File.delete(fs_path) }

  it "doesn't fail" do
    subject.perform(phenotype.id, user_phenotype.variation, 'user@example.com')

    mail = ActionMailer::Base.deliveries.last
    
    expect(mail.subject).to include('The data you requested is ready to be downloaded')
    mail.parts.each do |part|
      expect(part.body).to include("http://opensnp.org/#{file_path}")
    end
    expect(File.exist?(fs_path)).to be(true)
  end
end
