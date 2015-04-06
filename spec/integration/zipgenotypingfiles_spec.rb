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

  around { |example| Timecop.freeze(Time.new(2015, 4, 6, 10, 21), &example) }

  it "doesn't fail" do
    subject.perform(phenotype.id, user_phenotype.variation, 'user@example.com')

    mail = ActionMailer::Base.deliveries.last
    expect(mail.subject).to include('The data you requested is ready to be downloaded')
    expect(mail.body) .to include(
      "http://opensnp.org/data/zip/#{phenotype.id}.#{Time.now.strftime('%d.%m.%Y_%H_%M')}.zip")
  end
end
