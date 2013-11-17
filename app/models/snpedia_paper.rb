class SnpediaPaper < ActiveRecord::Base
  has_many :references, as: :paper
  has_many :snps, through: :references

  searchable do
    text :summary
  end
end
