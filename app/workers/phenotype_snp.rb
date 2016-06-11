class SnpToPhenotype
  include Sidekiq::Worker
  sidekiq_options :queue => :snp_phenotype, :retry => 5, :unique => true
  attr_reader :snp, :client

  def perform(snp_id)
    # could possibly use the max_age limit here
    @psnp = PhenotypeSnp.where(:snp_id => snp_id)
    @characteristics = Phenotypes.all.map { |x| x.characteristic }
    @papers_count = 0
    psnp.map { |x| score_phenotype(x) }
  end

  def score_phenotype (psnp)
    # TODO:
    # - fetch all the stored phenotypes
    # (available in @characteristics)

    # - fetch papers metadata corresponding to the SNP
    plos = score_paper(:plos_papers, 2)
    snpedia = score_paper(:snpedia_papers, 5)
    pgp = score_paper(:pgp_annotation, 2)
    genomegov = score_paper(:genome_gov_papers, 2)
    mendeley = score_paper(:mendeley_papers, 1)

    all_scores = [snpedia, pgp, genomegov, mendeley].reduce(plos) do |x, y|
      x.merge(y) do |k, v1, v2|
        v1 + v2
      end
    end

    all_scores.sort_by! {|k, v| v}

    all_scores.take(10) do |k, v|
      ph = Phenotype.find_by_characteristic(k)
      PhenotypeSnp.find_or_initialize_by(:snp_id => psnp)
                  .update_attributes!(:phenotype_id => ph, :score => v)
    end
  end

  def score_paper(paper_type, weight)
    # - search for each phenotype one by one in the papers' metadata
    score = {}

    papers = psnp.public_send(paper_type)
    papers_count += papers.length

    characteristics.each do |chr|
      papers.each do |p|
        if p.title.downcase.include? chr.douwncase
          score[chr.downcase] = weight + score[chr.downcase] || 0
        end
      end
      score[chr.downcase] /= papers.length
    end
    score
  end
end
