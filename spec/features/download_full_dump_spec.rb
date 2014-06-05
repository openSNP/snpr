require 'spec_helper'

feature 'downloading the full dump' do
  let(:current_user) { create(:user) }
  let(:zip_path) { Rails.root.join('public/data/zip/test.zip') }
  let(:link_path) { Rails.root.join('public/data/zip/opensnp_datadump.current.zip') }
  let(:public_path) { '/data/zip/opensnp_datadump.current.zip' }

  background do
    allow_any_instance_of(ApplicationController).to receive(:current_user).
      and_return(current_user)
  end

  before do
    FileUtils.cp(Rails.root.join('spec/fixtures/files/test.zip'), zip_path)
    FileUtils.ln_sf(zip_path, link_path)
  end

  after do
    FileUtils.rm(zip_path)
  end

  scenario 'sends the zip file if it exists' do
    visit('/genotypes')
    click_link('Download the dump')
    expect(page.body).to eq(File.binread(zip_path))
    expect(page.response_headers['Content-Type']).to eq('application/zip')
  end
end
