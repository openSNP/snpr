require 'zip/zip'
require 'zip/zipfilesystem'

class SearchResult < ActiveRecord::Base

	def bundle(genotypes)
		if not genotypes.empty?
			file_name = "genotypes.zip"
			t = Tempfile.new('temp_genotypes-#{Time.now}') # change this to something truly unique
			Zip::ZipOutputStream.open(t.path) do |z|
				genotypes.each do |gen|
					title = gen.title
					title += ".txt"
					z.put_next_entry(title)
					z.print IO.read(gen.path)
				end
			end
			send_file t.path, :type => 'application/zip',
				:disposition => 'attachment',
				:filename => file_name
		end
	end
end
