class UserSnp
  attr_reader :snp, :genotype
  delegate :user, to: :genotype

  def initialize(snp, genotype, local_genotype = nil)
    @snp = snp
    @genotype = genotype
    @local_genotype = local_genotype if local_genotype
  end

  def local_genotype
    return @local_genotype if defined?(@local_genotype)

    snp_name = ActiveRecord::Base.sanitize(snp.name)
    @local_genotype = SnpsByGenotype.where(genotype_id: genotype.id)
                                    .pluck("snps -> #{snp_name}")
                                    .first
  end

  def local_genotype=(variation)
    @local_genotype = variation
  end

  def save
    ActiveRecord::Base.transaction do
      GenotypesBySnp.find_or_create_by(snp_name: snp.name)
      GenotypesBySnp
        .where(snp_name: snp.name)
        .update_all("genotypes = genotypes || hstore('#{genotype.id}', '#{@local_genotype}')")
      SnpsByGenotype.find_or_create_by(genotype_id: genotype.id)
      SnpsByGenotype
        .where(genotype_id: genotype.id)
        .update_all("snps = snps || hstore('#{snp.name}', '#{@local_genotype}')")
    end
    self
  end
end
