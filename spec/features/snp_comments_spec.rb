RSpec.feature 'Commenting on SNPs' do
  let(:user) { create(:user) }
  let!(:snp) { create(:snp) }

  before do
    sign_in(user)
  end

  scenario 'a user comments on an SNP' do
    visit "/snps/#{snp.name}"

    fill_in('Subject', with: 'Hello!')
    fill_in('Comment text', with: 'This is a great SNP!')
    click_on('Comment')

    expect(page).to have_content('Hello!')
    expect(page).to have_content('This is a great SNP!')

    expect(SnpComment.last).to have_attributes(
      snp_id: snp.id,
      user_id: user.id,
      subject: 'Hello!',
      comment_text: 'This is a great SNP!'
    )
  end
end
