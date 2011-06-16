require 'fileutils'

class Genotype < ActiveRecord::Base
 belongs_to  :user
 has_many :snps
 
validates_presence_of :originalfilename, :message => "Please provide file"

def initialize
 super
 @tmp_file_name=rand(999999).to_s
end

def fs_filename
 return user.id.to_s+"."+filetype.to_s+"."+id.to_s
end


def data
 if @tmp_file_name
  return File.open(RAILS_ROOT+"/public/data/"+@tmp_file_name).read
 else
  File.open(RAILS_ROOT+"/public/data/"+id.to_s).read
 end
end

def data=(filedata)
 if @tmp_file_name
  File.open(RAILS_ROOT+"/public/data/"+@tmp_file_name, "w") {|f| f.write(filedata)}
 else
  File.open(RAILS_ROOT+"/public/data/", "w") {|f| f.write(filedata)}
 end
end
 
def move_file
     FileUtils.move(RAILS_ROOT+"/public/data/"+@tmp_file_name, RAILS_ROOT+"/public/data/"+user.id.to_s+"."+filetype.to_s+"."+id.to_s)
end
 
end
