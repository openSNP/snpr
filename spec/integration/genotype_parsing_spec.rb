require 'spec_helper'

describe 'genotype parsing' do
  let(:file_23andMe) { Rails.root.join('test/data/23andMe_test.csv') }
  let(:genotype_23andme) do
    create(:genotype,
           genotype_file_name: file_23andMe.basename,
           filetype: '23andme')
  end


  let(:file_deCODEme) { Rails.root.join('test/data/deCODEme_test.csv') }
  let(:genotype_decodeme) do
    create(:genotype,
           genotype_file_name: file_deCODEme.basename,
           filetype: 'decodeme')
  end

  let(:temp_file) { Rails.root.join('tmp/snp_file.txt') }

  before do
    allow(Sidekiq::Client).to receive(:enqueue).with(Preparsing, an_instance_of(Fixnum))
    FileUtils.rm(temp_file) if File.exist?(temp_file)
  end

  it "parse 23andMe data", truncate: true do
    FileUtils.cp(file_23andMe, temp_file)
    Parsing.new.perform(genotype_23andme.id, temp_file)

    # Snp
    snp_data = Snp.all.map do |s|
      [ s.name, s.position, s.chromosome, s.genotype_frequency, s.allele_frequency, s.ranking ]
    end.sort_by { |s| s[0] }

    expected =
      [ [ "rs11240777", "788822", "1", {}, {"A"=>0, "T"=>0, "G"=>0, "C"=>0}, 0 ],
        [ "rs12124819", "766409", "1", {}, {"A"=>0, "T"=>0, "G"=>0, "C"=>0}, 0 ],
        [ "rs3094315",  "742429", "1", {}, {"A"=>0, "T"=>0, "G"=>0, "C"=>0}, 0 ],
        [ "rs3131972",  "742584", "1", {}, {"A"=>0, "T"=>0, "G"=>0, "C"=>0}, 0 ],
        [ "rs4477212",  "72017",  "1", {}, {"A"=>0, "T"=>0, "G"=>0, "C"=>0}, 0 ]]

      expect(snp_data).to eq(expected)

      # UserSnp
      user_snps = UserSnp.all
      user_snp_genotypes = user_snps.map(&:local_genotype)
      expected_genotypes = %w[ AA AA GG AG AG ]
      expect(user_snp_genotypes).to eq(expected_genotypes)
      user_snps.each do |s|
        expect(s.genotype_id).to eq(genotype_23andme.id)
        expect(Snp.pluck(:name)).to include(s.snp_name)
      end
  end

  # could put these deleting tests into their own file;
  # however, the genotyping exists at this point in time and we don't have to do any extra work
  # to pull it from the test DB
  it "delete 23andMe data" do
    DeleteGenotype.new.perform(genotype_23andme)

    expected = 0
    number_of_snps = Snp.all.count

    expect(number_of_snps).to eq(expected)
  end

  it "parse deCODEme data", truncate: true do
    FileUtils.cp file_deCODEme, temp_file
    Parsing.new.perform(genotype_decodeme.id, temp_file)

    # Snp
    snp_data = Snp.all.map do |s|
      [ s.name, s.position, s.chromosome, s.genotype_frequency, s.allele_frequency, s.ranking, s.user_snps_count ]
    end.sort_by { |s| s[0] }

    expected =
      [ [ "rs11240767", "718814", "1", {}, {"A"=>0, "T"=>0, "G"=>0, "C"=>0}, 0, 1],
        [ "rs2185539",  "556738", "1", {}, {"A"=>0, "T"=>0, "G"=>0, "C"=>0}, 0, 1],
        [ "rs3094315",  "742429", "1", {}, {"A"=>0, "T"=>0, "G"=>0, "C"=>0}, 0, 1],
        [ "rs4477212",  "72017",  "1", {}, {"A"=>0, "T"=>0, "G"=>0, "C"=>0}, 0, 1],
        [ "rs6681105",  "581938", "1", {}, {"A"=>0, "T"=>0, "G"=>0, "C"=>0}, 0, 1] ]

      expect(snp_data).to eq(expected)

      # UserSnp
      user_snps = UserSnp.all
      user_snp_genotypes = user_snps.map(&:local_genotype)
      expected_genotypes = %w[ AA CC TT CC TT ]
      expect(user_snp_genotypes).to eq(expected_genotypes)
      user_snps.each do |s|
        expect(s.genotype_id).to eq(genotype_decodeme.id)
        expect(Snp.pluck(:name)).to include(s.snp_name)
      end
  end

  it "delete deCODEme data" do
    DeleteGenotype.new.perform(genotype_decodeme)

    expected = 0
    number_of_snps = Snp.all.count

    expect(number_of_snps).to eq(expected)
  end
end
