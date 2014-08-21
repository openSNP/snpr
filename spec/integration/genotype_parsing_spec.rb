require 'spec_helper'

describe 'genotype parsing' do
  let(:temp_file) { Rails.root.join('tmp/snp_file.txt') }

  before do
    allow(Sidekiq::Client).to receive(:enqueue).with(Preparsing, an_instance_of(Fixnum))
    FileUtils.rm(temp_file) if File.exist?(temp_file)
  end

  context '23andMe' do
    let(:file) { File.open(Rails.root.join('test/data/23andMe_test.csv')) }
    let(:genotype) do
      create(:genotype, genotype: file, filetype: '23andme')
    end

    it 'parse 23andMe data', truncate: true do
      FileUtils.cp(file, temp_file)
      Parsing.new.perform(genotype.id)

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

      expect(snp_data).to eq(expected)

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

    # could put these deleting tests into their own file;
    # however, the genotyping exists at this point in time and we don't have to do any extra work
    # to pull it from the test DB
    it 'delete data' do
      DeleteGenotype.new.perform(genotype)
      expect(Snp.count).to eq(0)
    end
  end

  context 'deCODEme' do
    let(:file) { File.open(Rails.root.join('test/data/deCODEme_test.csv')) }
    let(:genotype) do
      create(:genotype, genotype: file, filetype: 'decodeme')
    end

    it 'parse deCODEme data', truncate: true do
      FileUtils.cp file, temp_file
      Parsing.new.perform(genotype.id)

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

      expect(snp_data).to eq(expected)

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

    it 'delete deCODEme data' do
      DeleteGenotype.new.perform(genotype)
      expect(Snp.count).to eq(0)
    end
  end
end
