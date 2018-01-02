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

    expect(page).to have_content('Your genotypes')

    within('#genotypes') do
      expect(find_all('table tbody tr td').map(&:text)).to eq(
        [
          '23andme',
          genotype.genotype_file_name,
          genotype.created_at.to_s,
          'queued',
          '0',
          'Delete'
        ]
      )
    end

    Preparsing.perform_async(genotype.id)

    visit current_url

    within('#genotypes') do
      expect(find_all('table tbody tr td').map(&:text)).to eq(
        [
          '23andme',
          genotype.genotype_file_name,
          genotype.created_at.to_s,
          'done',
          '5',
          'Delete'
        ]
      )
    end
  end
end
