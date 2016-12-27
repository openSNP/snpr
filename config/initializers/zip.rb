# frozen_string_literal: true
require "zip"
Zip.setup do |z|
  z.write_zip64_support = true
  z.unicode_names = true
  z.continue_on_exists_proc = true
end
