require 'spec_helper'

describe 'genotype parsing', sidekiq: :inline do
  before do
    # When running the background jobs inline, Paperclip hasn't saved the file,
    # yet. So we mock the after create hook and run the job manually.
    allow_any_instance_of(Genotype).to receive(:parse_genotype)
    Preparsing.new.perform(genotype.id)
  end

  after do
    expect(Genotype.count).to be(1)
    expect(UserSnp.count).to be(5)
    expect(Snp.count).to be(5)
    genotype.destroy
    expect(Genotype.count).to be_zero
    expect(UserSnp.count).to be_zero
    expect(Snp.count).to be_zero
  end

  context '23andMe' do
    let(:file) { File.open(Rails.root.join('test/data/23andMe_test.csv')) }
    let(:genotype) do
      create(:genotype, genotype: file, filetype: '23andme')
    end

    it 'parses 23andMe data', truncate: true do
      # Snp
      snp_data = Snp.all.map do |s|
        [s.name, s.position, s.chromosome, s.genotype_frequency,
         s.allele_frequency, s.ranking]
      end
      snp_data = snp_data.sort_by { |s| s[0] }

      expected = [
        ['rs11240777', '788822', '1', {}, { 'A' => 0, 'T' => 0, 'G' => 0, 'C' => 0 }, 0],
        ['rs12124819', '766409', '1', {}, { 'A' => 0, 'T' => 0, 'G' => 0, 'C' => 0 }, 0],
        ['rs3094315',  '742429', '1', {}, { 'A' => 0, 'T' => 0, 'G' => 0, 'C' => 0 }, 0],
        ['rs3131972',  '742584', '1', {}, { 'A' => 0, 'T' => 0, 'G' => 0, 'C' => 0 }, 0],
        ['rs4477212',  '72017',  '1', {}, { 'A' => 0, 'T' => 0, 'G' => 0, 'C' => 0 }, 0]
      ]

      expect(snp_data).to match_array(expected)

      # UserSnp
      user_snps = UserSnp.all
      user_snp_genotypes = user_snps.map(&:local_genotype)
      expected_genotypes = %w(AA AA GG AG AG)
      expect(user_snp_genotypes).to eq(expected_genotypes)
      user_snps.each do |s|
        expect(s.genotype_id).to eq(genotype.id)
        expect(Snp.pluck(:name)).to include(s.snp_name)
      end
    end
  end

  context 'deCODEme' do
    let(:file) { File.open(Rails.root.join('test/data/deCODEme_test.csv')) }
    let(:genotype) do
      create(:genotype, genotype: file, filetype: 'decodeme')
    end

    it 'parse deCODEme data', truncate: true do
      # Snp
      snp_data = Snp.all.map do |s|
        [s.name, s.position, s.chromosome, s.genotype_frequency,
         s.allele_frequency, s.ranking, s.user_snps_count]
      end.sort_by { |s| s[0] }

      expected = [
        ['rs11240767', '718814', '1', {}, { 'A' => 0, 'T' => 0, 'G' => 0, 'C' => 0 }, 0, 1],
        ['rs2185539',  '556738', '1', {}, { 'A' => 0, 'T' => 0, 'G' => 0, 'C' => 0 }, 0, 1],
        ['rs3094315',  '742429', '1', {}, { 'A' => 0, 'T' => 0, 'G' => 0, 'C' => 0 }, 0, 1],
        ['rs4477212',  '72017',  '1', {}, { 'A' => 0, 'T' => 0, 'G' => 0, 'C' => 0 }, 0, 1],
        ['rs6681105',  '581938', '1', {}, { 'A' => 0, 'T' => 0, 'G' => 0, 'C' => 0 }, 0, 1]
      ]

      expect(snp_data).to match_array(expected)

      # UserSnp
      user_snps = UserSnp.all
      user_snp_genotypes = user_snps.map(&:local_genotype)
      expected_genotypes = %w(AA CC TT CC TT)
      expect(user_snp_genotypes).to eq(expected_genotypes)
      user_snps.each do |s|
        expect(s.genotype_id).to eq(genotype.id)
        expect(Snp.pluck(:name)).to include(s.snp_name)
      end
    end
  end

  context 'ancestry' do
    let(:file) { File.open(Rails.root.join('test/data/ancestry_test.csv')) }
    let(:genotype) do
      create(:genotype, genotype: file, filetype: 'ancestry')
    end

    it 'parse ancestry data', truncate: true do
      # Snp
      snp_data = Snp.all.map do |s|
        [s.name, s.position, s.chromosome, s.genotype_frequency,
         s.allele_frequency, s.ranking, s.user_snps_count]
      end.sort_by { |s| s[0] }

      expected = [
        ['rs4477212', '82154', '1', {}, { 'A' => 0, 'T' => 0, 'G' => 0, 'C' => 0 }, 0, 1],
        ['rs3131972',  '752721', '1', {}, { 'A' => 0, 'T' => 0, 'G' => 0, 'C' => 0 }, 0, 1],
        ['rs12562034',  '768448', '1', {}, { 'A' => 0, 'T' => 0, 'G' => 0, 'C' => 0 }, 0, 1],
        ['rs11240777',  '798959',  '1', {}, { 'A' => 0, 'T' => 0, 'G' => 0, 'C' => 0 }, 0, 1],
        ['rs6681049',  '800007', '1', {}, { 'A' => 0, 'T' => 0, 'G' => 0, 'C' => 0 }, 0, 1]
      ]

      expect(snp_data).to match_array(expected)

      # UserSnp
      user_snps = UserSnp.all
      user_snp_genotypes = user_snps.map(&:local_genotype)
      expected_genotypes = %w(CC CC CC CC CC)
      expect(user_snp_genotypes).to eq(expected_genotypes)
      user_snps.each do |s|
        expect(s.genotype_id).to eq(genotype.id)
        expect(Snp.pluck(:name)).to include(s.snp_name)
      end
    end
  end

  context 'ftdna-illumina' do
    let(:file) { File.open(Rails.root.join('test/data/ftdna-illumina_sample.csv')) }
    let(:genotype) do
      create(:genotype, genotype: file, filetype: 'ftdna-illumina')
    end

    it 'parse ancestry data', truncate: true do
      # Snp
      snp_data = Snp.all.map do |s|
        [s.name, s.position, s.chromosome, s.genotype_frequency,
         s.allele_frequency, s.ranking, s.user_snps_count]
      end.sort_by { |s| s[0] }

      expected = [
        ['rs3094315', '752566', '1', {}, { 'A' => 0, 'T' => 0, 'G' => 0, 'C' => 0 }, 0, 1],
        ['rs3131972',  '752721', '1', {}, { 'A' => 0, 'T' => 0, 'G' => 0, 'C' => 0 }, 0, 1],
        ['rs12562034',  '768448', '1', {}, { 'A' => 0, 'T' => 0, 'G' => 0, 'C' => 0 }, 0, 1],
        ['rs12124819',  '776546',  '1', {}, { 'A' => 0, 'T' => 0, 'G' => 0, 'C' => 0 }, 0, 1],
        ['rs11240777',  '798959', '1', {}, { 'A' => 0, 'T' => 0, 'G' => 0, 'C' => 0 }, 0, 1]
      ]

      expect(snp_data).to match_array(expected)

      # UserSnp
      user_snps = UserSnp.all
      user_snp_genotypes = user_snps.map(&:local_genotype)
      expected_genotypes = %w(AA GG GG AA AG)
      expect(user_snp_genotypes).to eq(expected_genotypes)
      user_snps.each do |s|
        expect(s.genotype_id).to eq(genotype.id)
        expect(Snp.pluck(:name)).to include(s.snp_name)
      end
    end
  end
end
