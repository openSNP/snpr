# frozen_string_literal: true
class AddDefaultsForFrequenciesToSnps < ActiveRecord::Migration
  def change
    change_column :snps, :allele_frequency, :string, default: "---\nA: 0\nT: 0\nG: 0\nC: 0\n"
    change_column :snps, :genotype_frequency, :string, default: "--- {}\n"
    change_column :snps, :ranking, :integer, default: 0
  end
end
