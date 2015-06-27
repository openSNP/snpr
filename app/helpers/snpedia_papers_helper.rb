module SnpediaPapersHelper
  def bold_if_matching_local_genotype(snpedia_paper, user_snp, &block)
    if snpedia_paper && user_snp &&
        snpedia_paper.local_genotype == user_snp.local_genotype.split('').sort.join

      content_tag('b', &block)
    else
      capture(&block)
    end
  end
end
