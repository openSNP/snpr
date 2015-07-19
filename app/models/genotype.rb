require 'fileutils'

class Genotype < ActiveRecord::Base
  extend IgnoreColumns

  belongs_to :user
  has_many :user_snps
  validates_presence_of :user

  has_attached_file :genotype, url: '/data/:fs_filename',
                               path: "#{Rails.root}/public/data/:fs_filename"
  before_post_process :is_image?
  validates_attachment :genotype,
    presence: true,
    size: { in: 0..100.megabytes }
  do_not_validate_attachment_file_type :genotype

  after_create :parse_genotype

  ignore_columns :snps

  def snps
    snp_names = Genotype.unscoped.select('unnest(akeys(snps))').where(id: id)
    @snps ||= Snp.where(name: snp_names)
  end

  def self.with_local_genotype_for(snp)
    snp_name = case snp
               when Snp then snp.name
               when String then snp
               else fail TypeError "Expected Snp or String, got #{snp.class}"
               end
    select("snps -> '#{snp_name}' AS local_genotype")
  end

  def destroy
    ActiveRecord::Base.transaction do
      snps.update_all("genotypes = genotypes - '#{id}'::text")
      super
    end
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

  Paperclip.interpolates :fs_filename do |attachment, style|
    attachment.instance.fs_filename
  end
end
