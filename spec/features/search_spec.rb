# frozen_string_literal: true

require 'spec_helper'

feature 'search', :js do
  let!(:snp) { create(:snp, name: 'foo123') }
  let!(:phenotype) { create(:phenotype, characteristic: 'foonotype') }
  let!(:user) { create(:user, name: 'foobert') }
  let!(:snp_comment) { create(:snp_comment, subject: 'foo1A SNP', snp: snp, user: user) }
  let!(:phenotype_comment) { create(:phenotype_comment, subject: 'foo blubb') }
  let!(:mendeley_paper) { create(:mendeley_paper, title: 'foo_elsevier_content') }
  let!(:plos_paper) { create(:plos_paper, title: 'foo_OA_content') }
  let!(:snpedia_paper) { create(:snpedia_paper, summary: 'bar foo') }

  scenario 'searching' do
    # TODO: Add a button to the search field for a11y reasons.

    visit '/'

    fill_in 'search', with: 'foo'
    page.execute_script("document.getElementById('search').form.submit()")

    click_on('SNPs')
    expect(page).to have_content('foo123')

    click_on('Phenotypes')
    expect(page).to have_content('foonotype')

    click_on('Users')
    expect(page).to have_content('foobert')

    click_on('Comments')
    expect(page).to have_content('foo1A SNP')
    expect(page).to have_content('foo blubb')

    click_on('Papers')
    expect(page).to have_content('foo_elsevier_content')
    expect(page).to have_content('foo_OA_content')
    expect(page).to have_content('bar foo')
  end
end
