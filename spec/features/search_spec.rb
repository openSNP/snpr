require 'spec_helper'

feature 'search' do
  let!(:snp) { create(:snp, name: 'rs1234') }

  scenario 'searching' do
    visit '/'
    find(:css, '#search').set('rs123')
    click_on('Search')
    expect(find(:css, '#snps table')).to have_content('rs1234')
  end
end
