class Genotype < ActiveRecord::Base
 belongs_to  :user
 
validates_presence_of :originalfilename, :message => "Please provide file"

def fs_filename
 return user.id.to_s+"."+filetype.to_s+"."+id.to_s
end

def initialize
 super
 @tmp_file_name=rand(999999).to_s
end
 
def move_file
     File.move(@tmp_file_name, RAILS_ROOT+"/public/data/"+user.id.to_s+"."+filetype.to_s+"."+id.to_s)
end
 
end
