# frozen_string_literal: true

require 'spec_helper'

RSpec.describe "Widget management", :type => :request do

  let!(:snp) { create(:snp, name: 'rs2345') }
  let!(:user) { create(:user, name: 'API-Hacker',id: 1) }
  let!(:user_two) { create(:user, name: 'Dataless User', id: 2) }
  let!(:user_snp) { create(:user_snp, user: User.first, snp: Snp.first) }
  let!(:snpedia_paper) { create(:snpedia_paper, snps: [snp]) }


  it 'GET /snps/:id/1-3.json' do
    get "/snps/json/rs2345/1-3.json"
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
    expect(error_data['error']).to include("Sorry, we couldn't find any information for SNP rs2345 and user 3")
  end

  it 'GET annotations' do
    get "/snps/json/annotation/rs2345.json"
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
