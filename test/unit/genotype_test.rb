require_relative '../test_helper'

class GenotypeTest < ActiveSupport::TestCase
  context "Genotype" do
    setup do
      Genotype.any_instance.stubs(:fs_filename).returns("1.23andme.1")
    end

    should have_attached_file(:genotype)
    should validate_attachment_presence(:genotype)
    should validate_attachment_content_type(:genotype).
      allowing('text/plain', 'application/zip')
    should validate_attachment_size(:genotype).less_than(100.megabytes)
  end
end
