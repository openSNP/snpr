require 'spec_helper'

feature 'search' do
  let!(:snp) { create(:snp, name: 'rs1234') }

  scenario 'searching' do
    visit '/search?search=rs123'
    expect(find(:css, '#snps table')).to have_content('rs1234')
  end
end
