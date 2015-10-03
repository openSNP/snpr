require 'fileutils'

class Genotype < ActiveRecord::Base
  belongs_to :user
  has_many :user_snps
  has_one :snps_by_genotype, dependent: :delete
  validates_presence_of :user

  has_attached_file :genotype, url: '/data/:fs_filename',
                               path: "#{Rails.root}/public/data/:fs_filename"
  before_post_process :is_image?
  validates_attachment :genotype,
    presence: true,
    size: { in: 0..100.megabytes }
  do_not_validate_attachment_file_type :genotype

  after_create :parse_genotype
  before_destroy :delete_from_genotypes_by_snp

  def snps
    snp_names = SnpsByGenotype.select('unnest(akeys(snps))')
                              .from('snps_by_genotype')
                              .where(genotype_id: id)
    @snps ||= Snp.where(name: snp_names)
  end

  def self.with_local_genotype_for(snp)
    snp_name = case snp
               when Snp then snp.name
               when String then snp
               else fail TypeError, "Expected Snp or String, got #{snp.class}"
               end
    joins(:snps_by_genotype)
      .select('genotypes.*', "snps -> '#{snp_name}' AS local_genotype")
  end

  def is_image?
    false
  end

  def fs_filename
    "#{user.id}.#{filetype}.#{id}"
  end

  def parse_genotype
    Preparsing.perform_async(id)
  end

  private

  def delete_from_genotypes_by_snp
    GenotypesBySnp
      .where("genotypes ? '#{id}'")
      .update_all("genotypes = delete(genotypes, '#{id}')")
  end

  Paperclip.interpolates :fs_filename do |attachment, style|
    attachment.instance.fs_filename
  end
end
