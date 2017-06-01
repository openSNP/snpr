# frozen_string_literal: true
require 'set'
require 'open-uri'

class GenomeGov
  include Sidekiq::Worker
  sidekiq_options queue: :genomegov, retry: 5, unique: true
  attr_reader :known_snps

  def perform
    @known_snps = Snp.pluck(:name).to_set

    gwas_catalog  = open('http://www.genome.gov/admin/gwascatalog.txt') do |f|
      f.readlines
    end
    gwas_catalog.shift # remove CSV header
    gwas_catalog.each do |row|
      split_row = row.
        encode("UTF-8", invalid: :replace, undef: :replace, replace: "?").
        split("\t")
      process_row(split_row)
    end
  end

  def process_row(row)
    snp_name = row[21]
    pvalue   = row[27].to_f
    snp      = Snp.find_by_name(snp_name)
    return unless snp && pvalue < 1e-8 && known_snps.include?(snp_name.downcase)
    confidence_interval = row[31]
    pvalue_description  = row[29]
    first_author        = row[2]
    pub_date            = row[3]
    journal             = row[4]
    pubmed_link         = row[5]
    title               = row[6]
    trait               = row[7]
    if pvalue < 1e-100
      pvalue = 1e-100
    end
    paper = GenomeGovPaper.
      first_or_initialize(title: title, pubmed_link: pubmed_link)
    paper.update_attributes!(
      title:               title,
      pubmed_link:         pubmed_link,
      confidence_interval: confidence_interval,
      pvalue_description:  pvalue_description,
      pvalue:              pvalue,
      first_author:        first_author,
      pub_date:            pub_date,
      journal:             journal,
      trait:               trait,
      snps:                [snp],
    )
    snp.update_ranking
    snp.save
  end
end



