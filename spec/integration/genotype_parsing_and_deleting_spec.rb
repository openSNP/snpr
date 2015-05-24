describe 'genotype parsing', sidekiq: :inline do
  before do
    # When running the background jobs inline, Paperclip hasn't saved the file,
    # yet. So we mock the after create hook and run the job manually.
    allow_any_instance_of(Genotype).to receive(:parse_genotype)
    Preparsing.new.perform(genotype.id)
  end

  context '23andMe-exome-vcf' do
    let(:file) { File.open(Rails.root.join('test/data/23andmeexome_test.csv')) } 
    let(:genotype) do
      create(:genotype, genotype: file, filetype: '23andme-exome-vcf')
    end

    it 'parses 23andMe exome vcf data', truncate: true do
      snp_data = Snp.all.map do |s|
        [s.name, s.position, s.chromosome, s.genotype_frequency,
         s.allele_frequency, s.ranking]
      end
      snp_data = snp_data.sort_by { |s| s[0] }
      expected = [
        ['rs79585140', '14907', '1', {}, { 'A' => 0, 'T' => 0, 'G' => 0, 'C' => 0 }, 0],
        ['rs75454623', '14930', '1', {}, { 'A' => 0, 'T' => 0, 'G' => 0, 'C' => 0 }, 0],
        ['rs71252250', '15118', '1', {}, { 'A' => 0, 'T' => 0, 'G' => 0, 'C' => 0 }, 0],
        ['rs75062661', '69511', '1', {}, { 'A' => 0, 'T' => 0, 'G' => 0, 'C' => 0 }, 0],
        ['rs142727405', '663097', '1', {}, { 'A' => 0, 'T' => 0, 'G' => 0, 'C' => 0 }, 0],
      ]

      expect(snp_data).to match_array(expected)

      genotype.reload

      expect(genotype.snps).to eq(
        {
          'rs79585140' => 'AG',
          'rs75454623' => 'AG',
          'rs71252250' => 'AG',
          'rs75062661' => 'GG',
          'rs142727405' => 'CC',
        }
      )

      expect(Snp.pluck(:genotype_ids)).to eq([[genotype.id]]*5)
    end
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

      genotype.reload

      expect(genotype.snps).to eq(
        {
          "rs11240777" => "AG",
          "rs12124819" => "AG",
          "rs3094315" => "AA",
          "rs3131972" => "GG",
          "rs4477212" => "AA",
        }
      )

      expect(Snp.pluck(:genotype_ids)).to eq([[genotype.id]]*5)
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

      genotype.reload

      expect(genotype.snps).to eq(
        {
          "rs11240767" => "CC",
          "rs2185539" => "CC",
          "rs3094315" => "TT",
          "rs4477212" => "AA",
          "rs6681105" => "TT",
        }
      )

      expect(Snp.pluck(:genotype_ids)).to eq([[genotype.id]]*5)
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

      genotype.reload

      expect(genotype.snps).to eq(
        {
          "rs11240777" => "CC",
          "rs12562034" => "CC",
          "rs3131972" => "CC",
          "rs4477212" => "CC",
          "rs6681049" => "CC",
        }
      )

      expect(Snp.pluck(:genotype_ids)).to eq([[genotype.id]]*5)
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

      genotype.reload

      expect(genotype.snps).to eq(
        {
          "rs11240777" => "AG",
          "rs12124819" => "AA",
          "rs12562034" => "GG",
          "rs3094315" => "AA",
          "rs3131972" => "GG",
        }
      )

      expect(Snp.pluck(:genotype_ids)).to eq([[genotype.id]]*5)
    end
  end

  context 'IYG' do
    let(:file) { File.open(Rails.root.join('test/data/iyg_sample.csv')) }
    let(:genotype) do
      create(:genotype, genotype: file, filetype: 'IYG')
    end

    it 'parse ancestry data', truncate: true do
      # Snp
      snp_data = Snp.all.map do |s|
        [s.name, s.position, s.chromosome, s.genotype_frequency,
         s.allele_frequency, s.ranking, s.user_snps_count]
      end.sort_by { |s| s[0] }

      expected = [
        ['rs2131925', '1', '1', {}, { 'A' => 0, 'T' => 0, 'G' => 0, 'C' => 0 }, 0, 1],
        ['rs2815752', '1', '1', {}, { 'A' => 0, 'T' => 0, 'G' => 0, 'C' => 0 }, 0, 1],
        ['rs10924081', '1', '1', {}, { 'A' => 0, 'T' => 0, 'G' => 0, 'C' => 0 }, 0, 1],
        ['rs199838004', '3027',  'MT', {}, { 'A' => 0, 'T' => 0, 'G' => 0, 'C' => 0 }, 0, 1],
        ['rs41456348', '4336', 'MT', {}, { 'A' => 0, 'T' => 0, 'G' => 0, 'C' => 0 }, 0, 1]
      ]

      expect(snp_data).to match_array(expected)

      genotype.reload

      expect(genotype.snps).to eq(
        {
          "rs10924081" => "AA",
          "rs199838004" => "T",
          "rs2131925" => "GT",
          "rs2815752" => "AA",
          "rs41456348" => "T",
        }
      )

      expect(Snp.pluck(:genotype_ids)).to eq([[genotype.id]]*5)
    end
  end
end
