# frozen_string_literal: true

namespace :snps do
  desc "change mitochondrial snp names from 'mt' to 'm'."
  task :update_mt_snps => :environment do
    Snp.where(:chromosome => "MT").each do |s|
      s.chromosome = "M"
      s.position = s.position.strip
      s.save
    end
  end
end
