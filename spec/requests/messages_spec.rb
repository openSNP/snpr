# frozen_string_literal: true

RSpec.describe 'Messages' do
  let!(:alice) { create(:user, name: 'Alice') }
  let!(:bob) { create(:user, name: 'Bob') }

  let!(:to_alice) do
    create(:message, user: bob,
                     from_id: bob.id,
                     to_id: alice.id,
                     sent: true,
                     subject: 'Delete Me')
  end

  let!(:from_bob) do
    create(:message, user: alice,
                     from_id: bob.id,
                     to_id: alice.id,
                     subject: 'Delete Me')
  end

  before do
    sign_in(alice)
  end

  it "does not allow deleting other user's messages" do
    delete "/messages/#{to_alice.id}"

    follow_redirect!

    expect(response).to be_successful
    expect(response.body).to include('Oops! Thats none of your business')
  end
end
