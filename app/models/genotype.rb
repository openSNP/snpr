# frozen_string_literal: true

require 'fileutils'

class Genotype < ApplicationRecord
  belongs_to :user
  has_many :user_snps, dependent: :delete_all
  validates_presence_of :user

  has_attached_file :genotype, url: '/data/:fs_filename',
                               path: Rails.root.join('public/data/:fs_filename').to_s,
                               validate_media_type: false
  before_post_process :is_image?
  validates_attachment :genotype,
    presence: true,
    size: { in: 0..400.megabytes }
  do_not_validate_attachment_file_type :genotype

  def is_image?
    false
  end

  def fs_filename
    "#{user_id}.#{filetype}.#{id}"
  end

  Paperclip.interpolates :fs_filename do |attachment, style|
    attachment.instance.fs_filename
  end
end
