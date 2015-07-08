module SnpediaPapersHelper
  def bold_if_matching_variation(snpedia_paper, user_snp, &block)
    if snpedia_paper && user_snp &&
        snpedia_paper.snp_variation == user_snp.local_genotype.split('').sort.join

      content_tag('b', &block)
    else
      capture(&block)
    end
  end
end
