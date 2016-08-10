RSpec.describe LinkSnpPhenotype do
  setup do
    # might use 'build' if db transactions are not required
    @snp = FactoryGirl.create(:snp)
    @worker = LinkSnpPhenotype.new
    @document = {
      "uuid"         => UUIDTools::UUID.random_create.to_s,
      "title"        => "Test Driven Development And Why You Should Do It",
      "authors"      => [{ "forename" => "Max", "surname" => "Mustermann" }],
      "mendeley_url" => "http://example.com",
      "year"         => "2013",
      "doi"          => "456",
    }
  end

  describe 'worker' do
    after :each do
      LinkSnpPhenotype.clear
    end

    it 'does nothing if snp does not exist' do
      expect(@worker).not_to receive(:score_phenotype)
      @worker.perform(0)
    end

    it 'enqueues a task if phenotype_updated is less than MAX_AGE' do
      @snp.phenotype_updated = Time.now
      @worker.perform(@snp.id)

      expect(LinkSnpPhenotype.jobs).not_to be_empty
      expect(LinkSnpPhenotype.jobs.first['args']).to include(@snp.id)
    end

    it 'has no jobs if phenotype_updated is more than MAX_AGE' do
      @snp.phenotype_updated = 32.days.ago
      @worker.perform(@snp.id)

      expect(LinkSnpPhenotype.jobs).to be_empty
    end
  end

  describe 'scoring' do
    it 'returns no more than 10 phenotypes' do
      out = @worker.score_phenotype(@snp)
      expect(out.length).to be <= 10
    end

    it 'uses a consistent scoring scheme' do
    end
  end
end
