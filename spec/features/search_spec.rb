# frozen_string_literal: true
require 'spec_helper'

feature 'search' do
  let!(:snp) { create(:snp, name: 'foo123') }
  let!(:phenotype) { create(:phenotype, characteristic: 'foonotype') }
  let!(:user) { create(:user, name: 'foobert') }
  let!(:snp_comment) { create(:snp_comment, subject: 'foo1A SNP') }
  let!(:phenotype_comment) { create(:phenotype_comment, subject: 'foo blubb') }
  let!(:mendeley_paper) { create(:mendeley_paper, title: 'foo_elsevier_content') }
  let!(:plos_paper) { create(:plos_paper, title: 'foo_OA_content') }
  let!(:snpedia_paper) { create(:snpedia_paper, summary: 'bar foo') }

  scenario 'searching' do
    # TODO this currently does not work. redesign has no button to click on.

    visit '/'
    fill_in 'search', with: 'foo'

    form = page.find("form")
    class << form
      def submit!
        Capybara::RackTest::Form.new(driver, native).submit({})
      end
    end
    form.submit!

    expect(page).to have_content('foo123')
    expect(page).to have_content('foonotype')
    expect(page).to have_content('foobert')
    expect(page).to have_content('foo1A SNP')
    expect(page).to have_content('foo blubb')
    expect(page).to have_content('foo_elsevier_content')
    expect(page).to have_content('foo_OA_content')
    expect(page).to have_content('bar foo')
  end
end
