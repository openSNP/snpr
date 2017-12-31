# frozen_string_literal: true

RSpec.feature 'Upload a genotype' do
  let(:user) { create(:user, name: 'Gregor Mendel') }

  before do
    sign_in(user)
  end

  let(:genotype) { Genotype.last }

  scenario 'uploads first genotype' do
    visit '/genotypes/new'

    attach_file('genotype[genotype]', File.absolute_path('test/data/23andMe_test.csv'))
    choose '23andme-format'
    Sidekiq::Testing.disable! do
      click_on 'Upload'
      expect(page).to have_content('Genotype was successfully uploaded!')
      expect(page).to have_content("You've unlocked an achievement:")
    end

    expect(genotype.reload.parse_status).to eq('queued')
    Preparsing.perform_async(genotype.id)
    expect(genotype.reload.parse_status).to eq('done')
    expect(genotype.user_snps).to be_present
  end
end
