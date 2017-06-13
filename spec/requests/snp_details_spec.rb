# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'SNP-API', type: :request do

  let!(:snp) { create(:snp, name: 'rs2345') }
  let!(:user) { create(:user, name: 'API-Hacker') }
  let!(:user_two) { create(:user, name: 'Dataless User') }
  let!(:user_snp) { create(:user_snp, user: user, snp: snp) }
  let!(:snpedia_paper) { create(:snpedia_paper, snps: [snp]) }

  it 'GET /snps/:id/1-3.json' do
    search = "#{user.id},#{user_two.id},#{User.last.id + 1}"
    get "/snps/json/rs2345/#{search}.json"
    assert_response :success
    data = JSON.parse(response.body)
    expect(data).to_not be_empty
    data_user1 = data[0]
    data_user2 = data[1]
    error_data = data[2]
    %w(name chromosome position).each do |property|
      expect(data_user1['snp'].keys).to include(property)
    end
    %w(name id genotypes).each do |property|
      expect(data_user1['user'].keys).to include(property)
    end
    expect(data_user2['user']['genotypes']).to be_empty
    expect(error_data['error']).to include("Sorry, we couldn't find any")
  end

  it 'GET annotations' do
    get '/snps/json/annotation/rs2345.json'
    assert_response :success
    data = JSON.parse(response.body)
    expect(data).to_not be_empty
    expect(data['snp']['annotations']).to_not be_empty
    expect(data['snp']['annotations']['snpedia']).to_not be_empty
    %w(pgp_annotations genome_gov_publications plos mendeley).each do |source|
      expect(data['snp']['annotations'][source]).to be_empty
    end
  end
end
