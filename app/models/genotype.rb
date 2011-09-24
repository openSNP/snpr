require 'fileutils'

class Genotype < ActiveRecord::Base
  belongs_to :user
  has_many :user_snps

  validates_presence_of :originalfilename, :message => "Please provide a genotyping file"
  validates_presence_of :user

  def initialize
    super
    @tmp_file_name=rand(999999).to_s
  end

  def fs_filename
    return user.id.to_s+"."+filetype.to_s+"."+id.to_s
  end

  def data
    if @tmp_file_name
      return File.open(::Rails.root.to_s+"/public/data/"+@tmp_file_name).read
    else
      File.open(::Rails.root.to_s+"/public/data/"+id.to_s).read
    end
  end

  def data=(filedata)
    if @tmp_file_name
      File.open(::Rails.root.to_s+"/public/data/"+@tmp_file_name, "w") {|f| f.write(filedata)}
    else
      File.open(::Rails.root.to_s+"/public/data/", "w") {|f| f.write(filedata)}
    end
  end

  def move_file
    FileUtils.move(::Rails.root.to_s+"/public/data/"+@tmp_file_name, ::Rails.root.to_s+"/public/data/"+user.id.to_s+"."+filetype.to_s+"."+id.to_s)
  end

  def delete_file
    FileUtils.rm(::Rails.root.to_s+"/public/data/"+user.id.to_s+"."+filetype.to_s+"."+id.to_s)
  end

  def download
    return "/data/"+user.id.to_s+"."+filetype.to_s+"."+id.to_s
  end
end
