require 'spec_helper'

feature 'search' do
  let!(:snp) { create(:snp, name: 'rs123') }

  scenario 'searching' do
    visit '/search?search=rs123'
    expect(page).to have_content('rs123')
  end
end
