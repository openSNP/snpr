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
    @local_genotype = Genotype.unscoped
                              .select("snps -> #{snp_name} AS local_genotype")
                              .where(id: genotype.id)
                              .first
                              .local_genotype
  end

  def local_genotype=(variation)
    @local_genotype = variation
  end

  def save
    ActiveRecord::Base.transaction do
      Snp.unscoped
         .where(id: snp.id)
         .update_all("genotypes = genotypes || hstore('#{genotype.id}', '#{@local_genotype}')")
      Genotype.unscoped
              .where(id: genotype.id)
              .update_all("snps = snps || hstore('#{snp.name}', '#{@local_genotype}')")
    end
    self
  end
end
