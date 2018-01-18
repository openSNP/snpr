# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'DAS-API', type: :request do

  let!(:user) { create(:user, name: 'API-Hacker',id: 1) }
  let!(:genotype) { create(:genotype,id: 1,user: user) }
  let!(:snp) { create(:snp, name: 'rs2345', chromosome: 1, position: 10) }
  let!(:snp_two) { create(:snp, name: 'rs1234', chromosome: 1, position: 12) }
  let!(:user_snp) { create(:user_snp, user: user, snp: snp, genotype: genotype) }
  let!(:user_snp_two) { create(:user_snp, user: user, snp: snp_two, genotype: genotype) }

  it 'GET /das/:id/' do
    get "/das/#{user.id}/features?segment=1:10,11",
      nil,
      'SERVER_SOFTWARE' => 'faked for test'
    assert_response :success
    expect(response.body).to include('rs2345')
    expect(response.body).not_to include('rs1234')
  end
end
