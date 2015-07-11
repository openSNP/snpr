class UserSnp
  attr_reader :snp, :genotype

  def initialize(snp, genotype)
    @snp = snp
    @genotype = genotype
  end

  def local_genotype
    return @local_genotype if defined?(@local_genotype)

    snp_name = ActiveRecord::Base.sanitize(snp.name)
    @local_genotype = Genotype.unscoped
                              .select("snps -> #{snp_name} AS local_genotype")
                              .where(id: genotype.id)
                              .first
                              .local_genotype
  end
end
