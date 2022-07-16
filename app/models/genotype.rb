# frozen_string_literal: true
require 'fileutils'

class Genotype < ActiveRecord::Base
  belongs_to :user
  has_many :user_snps, dependent: :delete_all
  validates_presence_of :user

  has_attached_file :genotype, url: '/data/:fs_filename',
                               path: "#{Rails.root}/public/data/:fs_filename",
                               validate_media_type: false
  before_post_process :is_image?
  validates_attachment :genotype,
    presence: true,
    size: { in: 0..400.megabytes }

  def is_image?
    false
  end

  def fs_filename
    "#{user.id}.#{filetype}.#{id}"
  end

  Paperclip.interpolates :fs_filename do |attachment, style|
    attachment.instance.fs_filename
  end
end
