require 'spec_helper'

describe 'phenotypes API', focus: true do
  # Get all phenotypes entered
  it 'GET /phenotypes returns list of phenotypes' do
    create_list(:phenotype, 3)
    get '/phenotypes.json'
    assert_response :success
    data = JSON.parse(response.body)
    expect(data).to_not be_empty
  end

  # Get all known variations and all users sharing that phenotype for one phenotype(-ID)
  it 'GET /phenotypes/json/variations/:id' do
    create(:phenotype_with_users)
    get "/phenotypes/json/variations/#{Phenotype.first.id}.json"
    assert_response :success
    data = JSON.parse(response.body)
    %w{id characteristic description known_variations users}.each do |property|
      expect(data.keys).to include(property)
    end
    expect(data['users']).to_not be_empty
    expect(data['users'].first.keys).to include('user_id')
    expect(data['users'].first.keys).to include('variation')
  end

  # Get all phenotypes from a specific user(-ID)
  it 'get /phenotypes/json/:id.json' do
    phenotype = create(:phenotype_with_users)
    get "/phenotypes/json/#{phenotype.user_phenotypes.first.user_id}.json"
    assert_response :success
    data = JSON.parse(response.body)
    expect(data.keys).to include('user')
    expect(data.keys).to include('phenotypes')
  end

  # Get all phenotypes from a range of user-IDs
  it 'get /phenotypes/json/:id.json' do
    phenotypes = create_list(:phenotype_with_users, 3)
    ids = phenotypes.map(&:user_phenotypes).flatten.map(&:user_id)
    range = "#{ids.min}-#{ids.max}"
    get "/phenotypes/json/#{range}.json"
    assert_response :success
    data = JSON.parse(response.body)
    expect(data.size).to eq(ids.size)
    expect(data.sample.keys).to include('user')
    expect(data.sample.keys).to include('phenotypes')
    expect(data.sample['phenotypes']).to be_a(Hash)
    expect(data.sample['user']['name']).to_not be_nil
    expect(data.sample['user']['id']).to_not be_nil
  end

  # Get all phenotypes for certain user(ID)s 1, 3 and 10
  it 'get /phenotypes/json/:id.json' do
    phenotypes = create_list(:phenotype_with_users, 3)
    ids = phenotypes.map(&:user_phenotypes).flatten.map(&:user_id)
    range = ids.sample(2).join(',')
    get "/phenotypes/json/#{range}.json"
    assert_response :success
    data = JSON.parse(response.body)
    expect(data.size).to eq(2)
    expect(data.sample.keys).to include('user')
    expect(data.sample.keys).to include('phenotypes')
    expect(data.sample['phenotypes']).to be_a(Hash)
    expect(data.sample['user']['name']).to_not be_nil
    expect(data.sample['user']['id']).to_not be_nil
  end
end
