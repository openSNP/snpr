RSpec.feature 'Phenotype recommendation' do
  let!(:user) { create(:user) }
  let!(:phenotype1) do
    create(:phenotype, characteristic: 'Eye count',
                       description: 'How many eyes do you have?')
  end
  let!(:phenotype2) do
    create(:phenotype, characteristic: 'Tentacle count',
                       description: 'How many tentacles do you have?')
  end
  let!(:phenotype3) do
    create(:phenotype, characteristic: 'Beard color',
                       description: 'What is the color of your beard?')
  end
  let(:other_user) { create(:user) }

  before do
    sign_in(user)

    create(:user_phenotype, user: other_user, phenotype: phenotype1, variation: '10')
    create(:user_phenotype, user: other_user, phenotype: phenotype2, variation: '1000')
    create(:user_phenotype, user: other_user, phenotype: phenotype3, variation: 'red')

    PhenotypeRecommender.new.update
    VariationRecommender.new.update
  end

  scenario 'the user enters a new variation' do
    visit('/phenotypes')
    click_on('Eye count')
    fill_in('Enter your phenotype now', with: '10') # TODO: Make this work
    click_on('Submit your variation')

    expect(page).to have_content('Similar Variations')
    expect(page).to have_content(<<-TXT.strip_heredoc)
      You have just entered that 10 is your variation for the phenotype Eye \
      count. Below you can find 2 phenotypes and the answers which are \
      most-often entered by users who also gave 10 as their variation for Eye \
      count.
    TXT
    expect(page).to have_content(<<-TXT.strip_heredoc)
      Tentacle count Users with phenotypic variation similar to yours often \
      gave 1000 as variation for this phenotype. What about you?
    TXT
    expect(page).to have_content(<<-TXT.strip_heredoc)
      Beard color Users with phenotypic variation similar to yours often gave \
      red as variation for this phenotype. What about you?
    TXT

    expect(page).to have_content('Similar Phenotypes')
    expect(page).to have_content(<<-TXT.strip_heredoc)
      Below you can find 2 phenotypes which are often entered by users who \
      provided us with any information about Eye count.
    TXT
    expect(page).to have_content(
      'Tentacle count Description: How many tentacles do you have?'
    )
    expect(page).to have_content(
      'Beard color Description: What is the color of your beard?'
    )
  end
end
