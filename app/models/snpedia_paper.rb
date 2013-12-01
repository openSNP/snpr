class SnpediaPaper < ActiveRecord::Base
  has_many :snp_references, as: :paper
  has_many :snps, through: :snp_references

  searchable do
    text :summary
  end
end
