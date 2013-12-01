class PlosPaper < ActiveRecord::Base
  has_many :snp_references, as: :paper
  has_many :snps, through: :snp_references

  searchable do
    text :title
  end
end
