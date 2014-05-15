require 'fileutils'

class Genotype < ActiveRecord::Base
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

  attr_accessible :genotype, :filetype, :user_id, :md5sum
  after_create :parse_genotype
  before_destroy :delete_genotype

  def is_image?
    false
  end

  def fs_filename
    "#{user.id}.#{filetype}.#{id}"
  end

  def parse_genotype
    Sidekiq::Client.enqueue(Preparsing, id)
  end

  def delete_genotype
    Sidekiq::Client.enqueue(DeleteGenotype, { genotype_id: id })
  end

  Paperclip.interpolates :fs_filename do |attachment, style|
    attachment.instance.fs_filename
  end
end
