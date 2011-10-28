require 'resque'

class Frequency
  @queue = :frequency

  def self.perform(snp_id)
    s = Snp.find_by_id(snp_id)
    s.allele_frequency ||= { "A" => 0, "T" => 0, "G" => 0, "C" => 0}
    s.genotype_frequency ||= {}
    UserSnp.where(:snp_name => s.name).find(:all).each do |us|
      if s.allele_frequency.has_key?(us.local_genotype[0].chr)
        s.allele_frequency[us.local_genotype[0].chr] += 1
      else
        s.allele_frequency[us.local_genotype[0].chr] = 1
      end

      if us.local_genotype.length > 1
        if s.allele_frequency.has_key?(us.local_genotype[1].chr)
          s.allele_frequency[us.local_genotype[1].chr] +=  1
        else
          s.allele_frequency[us.local_genotype[1].chr] = 1
        end
      end

      if s.genotype_frequency.has_key?(us.local_genotype.rstrip)
        s.genotype_frequency[us.local_genotype.rstrip] +=  1

      elsif us.local_genotype.length > 1
        if s.genotype_frequency.has_key?(us.local_genotype[1].chr+us.local_genotype[0].chr)
          s.genotype_frequency[us.local_genotype[1].chr+us.local_genotype[0].chr] +=  1
        else
          s.genotype_frequency[us.local_genotype.rstrip] = 1
        end
      else
        s.genotype_frequency[us.local_genotype.rstrip] = 1
      end
    end
    s.save
  end
end