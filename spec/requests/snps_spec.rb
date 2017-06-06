# frozen_string_literal: true
require 'spec_helper'

describe 'SNP API', focus: true do
  it 'GET /snps/:id.json' do
    create(:snp, name: 'rs1234')
    create(:user) { create(:user, name: 'API-Hacker') }
    create(:user_snp) {create(:user_snp,user: User.first,snp: Snp.first)}
    get "/snps/rs1234.json"
    assert_response :success
    data = JSON.parse(response.body)
    expect(data).to_not be_empty
    data = data[0]
    %w(name chromosome position).each do |property|
      expect(data["snp"].keys).to include(property)
    end
    %w(name id genotypes).each do |property|
      expect(data["user"].keys).to include(property)
    end

  end
end
