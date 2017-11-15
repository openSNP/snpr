# frozen_string_literal: true
# simple Beacon implementation according to the GA4GH v0.2 standard
# see http://dnastack.com/ga4gh/bob/subscribe.html
# chrom={chromosome}&
# pos={position}&
# allele={allele}

class BeaconController < ApplicationController
  def responses
    begin
      @position = params[:pos].to_i
      @chromosome = params[:chrom]
      @allele = params[:allele].upcase
      # get all snps, iterate over them:
      # if found the allele: return yes & break
      @snps = Snp.where(position: @position, chromosome: @chromosome)
      @snps.each do |s|
        if s.allele_frequency[@allele].positive?
          render text: 'YES' and return
          break
        end
      end
      # not found? return no
      render text: 'NO' and return
    rescue
      # did something break: return none (not useful, but the API standard…)
      render text: 'NONE'
    end
  end
end
