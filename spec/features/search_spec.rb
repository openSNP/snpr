# frozen_string_literal: true
require 'spec_helper'

feature 'search' do
  let!(:snp) { create(:snp, name: 'foo123') }
  let!(:phenotype) { create(:phenotype, characteristic: 'foo') }
  let!(:user) { create(:user, name: 'Foobert') }
  let!(:snp_comment) { create(:snp_comment, subject: 'foo') }
  let!(:phenotype_comment) { create(:phenotype_comment, subject: 'foo') }
  let!(:mendeley_paper) { create(:mendeley_paper, title: 'foo') }
  let!(:plos_paper) { create(:plos_paper, title: 'foo') }
  let!(:snpedia_paper) { create(:snpedia_paper, summary: 'bar foo') }

  scenario 'searching' do
    visit '/'
    find(:css, '#search').set('foo').send_keys(:return)

    within('#tab-container') do
      expect(find(:css, '#snps')).to have_content('foo123')

      click_on('Phenotypes')
      expect(find(:css, '#phenotypes')).to have_content('foo')

      click_on('Users')
      expect(find(:css, '#users')).to have_content('Foobert')

      click_on('Comments')
      expect(find(:css, '#snp-comments')).to have_content('foo')

      click_on('Comments')
      expect(find(:css, '#phenotype-comments')).to have_content('foo')

      click_on('Papers')
      expect(find(:css, '#mendeley-papers')).to have_content('foo')

      click_on('Papers')
      expect(find(:css, '#plos-papers')).to have_content('foo')

      click_on('Papers')
      expect(find(:css, '#snpedia-papers')).to have_content('bar foo')
    end
  end
end
