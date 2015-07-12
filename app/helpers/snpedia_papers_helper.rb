module SnpediaPapersHelper
  def strong_if_matching_variation(snpedia_paper, user_snp, &block)
    if snpedia_paper && user_snp &&
        snpedia_paper.snp_variation == user_snp.local_genotype.split('').sort.join

      content_tag('strong', &block)
    else
      capture(&block)
    end
  end
end
