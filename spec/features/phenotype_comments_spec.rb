# frozen_string_literal: true
RSpec.feature 'Phenotype comments' do
  let(:user) { create(:user) }
  let(:phenotype) { create(:phenotype) }

  before do
    sign_in(user)
  end

  scenario 'a user comments on a phenotype' do
    visit "/phenotypes/#{phenotype.id}"

    click_on('Comments')

    fill_in('Subject', with: 'Some subject')
    fill_in('Comment text', with: 'Some comment')

    click_on('Comment')

    comment = PhenotypeComment.last
    expect(comment.subject).to eq('Some subject')
    expect(comment.comment_text).to eq('Some comment')
    expect(comment.phenotype_id).to eq(phenotype.id)
  end
end
