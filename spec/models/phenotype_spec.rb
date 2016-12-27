# frozen_string_literal: true
RSpec.describe Phenotype do
  describe '#known_phenotypes' do
    let(:user_phenotypes) { class_double(UserPhenotype) }

    it 'strips out duplicates' do
      allow(subject).to receive(:user_phenotypes).and_return(user_phenotypes)
      allow(user_phenotypes).to receive(:pluck).and_return(
        ['Ping pong', 'ping pong', 'Ping Pong', 'PING PONG', 'Table tennis']
      )
      expect(subject.known_phenotypes).to eq(['Ping pong', 'Table tennis'])
    end
  end
end
