require_relative '../test_helper'

class ParsingTest < ActiveSupport::TestCase
  context "parser" do
    setup do
      Sunspot.stubs(:index)
      Snp.delete_all
      UserSnp.delete_all

      @file_23andMe = "#{Rails.root}/test/data/23andMe_test.txt"
      @genotype = Factory :genotype,
        originalfilename: @file_23andMe.split('/').last #, data: @genotype_data
    end

    should "parse 23andMe data" do
      FileUtils.cp @file_23andMe, 
        "#{Rails.root}/public/data/#{@genotype.user.id}.#{@genotype.filetype}.#{@genotype.id}"
      Parsing.perform('genotype' => @genotype.attributes)

      # Snp
      snp_data = Snp.all.map do |s|
        [ s.name, s.position, s.chromosome, s.genotype_frequency, s.allele_frequency, s.ranking ]
      end

      expected =
        [[ "rs4477212",  "72017",  "1", {"AA"=>1}, {"A"=>2, "T"=>0, "G"=>0, "C"=>0}, "0" ],
         [ "rs3094315",  "742429", "1", {"AA"=>1}, {"A"=>2, "T"=>0, "G"=>0, "C"=>0}, "0" ],
         [ "rs3131972",  "742584", "1", {"GG"=>1}, {"A"=>0, "T"=>0, "G"=>2, "C"=>0}, "0" ],
         [ "rs12124819", "766409", "1", {"AG"=>1}, {"A"=>1, "T"=>0, "G"=>1, "C"=>0}, "0" ],
         [ "rs11240777", "788822", "1", {"AG"=>1}, {"A"=>1, "T"=>0, "G"=>1, "C"=>0}, "0" ]]

      assert_equal expected, snp_data

      # UserSnp
      user_snps = UserSnp.all
      user_snp_genotypes = user_snps.map(&:local_genotype)
      expected_genotypes = %w[ AA AA GG AG AG ]
      assert_equal expected_genotypes, user_snp_genotypes
      snp_ids = Snp.all.map(&:id)
      user_snps.each do |s|
        assert_equal @genotype.id, s.genotype_id
        assert_equal @genotype.user.id, s.user_id
        assert snp_ids.include?(s.snp_id)
      end
    end
  end
end
