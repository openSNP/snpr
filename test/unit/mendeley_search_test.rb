require_relative '../test_helper'

class MendeleySearchTest < ActiveSupport::TestCase
  context "worker" do
    setup do
      stub_solr
      @snp = FactoryGirl.create(:snp)
      @worker = MendeleySearch.new
      @document = {
        "uuid"         => UUIDTools::UUID.random_create.to_s,
        "title"        => "Test Driven Development And Why You Should Do It",
        "authors"      => [{ "forename" => "Max", "surname" => "Mustermann" }],
        "mendeley_url" => "http://example.com",
        "year"         => "2013",
        "doi"          => "456",
      }
    end

    should "do nothing if snp does not exist" do
      @worker.expects(:search).never
      @worker.expects(:update_mendeley?).never
      @worker.perform(0)
    end

    context "with existing snp" do
      setup do
        Snp.stubs(:where).returns(Snp)
        Snp.stubs(:first).returns(@snp)
      end

      # TODO: fix mendeley worker
      #should "search for papers if the last update was too long ago" do
      #  @worker.expects(:search)
      #  @snp.stubs(:mendeley_updated).returns(32.days.ago)
      #  @worker.perform(@snp.id)
      #end

      should "not search for papers if the last update was not too long ago" do
        @worker.expects(:search).never
        @snp.stubs(:mendeley_updated).returns(30.days.ago)
        @worker.perform(@snp.id)
      end

      # TODO: fix mendeley worker
      #should "search for papers if snp was never searched for" do
      #  @worker.expects(:search)
      #  @snp.stubs(:mendeley_updated).returns(nil)
      #  @worker.perform(@snp.id)
      #end
    end

    context "searched-for papers" do
      setup do
        @worker.stubs(:snp).returns(@snp)
      end

      should "be processed" do
        Mendeley::API::Documents.expects(:search).
          with("\"#{@snp.name}\"", { items: 500, page: 0 }).
          returns({ "documents" => [@document] })
        @worker.expects(:process_documents).with([@document])

        @snp.expects(:mendeley_updated=).with do |time|
          assert time.is_a?(Time)
        end
        @snp.expects(:ranking=)
        @snp.expects(:save).returns(true)

        @worker.search
      end
    end

    context "processing documents" do
      setup do
        @worker.stubs(:snp).returns(@snp)
      end

      should "create papers that do not already exist" do
        uuid = @document["uuid"]
        new_mendeley_paper = MendeleyPaper.new(uuid: uuid)
        MendeleyPaper.expects(:find_or_initialize_by_uuid).with(uuid).
          returns(new_mendeley_paper)
        new_mendeley_paper.expects(:save).returns(true)
        Sidekiq::Client.expects(:enqueue).with do |klass, id|
          assert_equal(MendeleyDetails, klass)
        end

        @worker.process_documents([@document])

        assert_equal [@snp], new_mendeley_paper.snps
        assert_equal @document["title"], new_mendeley_paper.title
        assert_equal @document["mendeley_url"], new_mendeley_paper.mendeley_url
        assert_equal "Max Mustermann", new_mendeley_paper.first_author
        assert_equal @document["year"].to_i, new_mendeley_paper.pub_year
        assert_equal @document["uuid"], new_mendeley_paper.uuid
        assert_equal @document["doi"], new_mendeley_paper.doi
      end

      should "not update existing valid papers" do
        uuid = @document["uuid"]
        existing_mendeley_paper = FactoryGirl.
          build_stubbed(:mendeley_paper, uuid: uuid, snps: [@snp])
        MendeleyPaper.expects(:find_or_initialize_by_uuid).with(uuid).
          returns(existing_mendeley_paper)
        MendeleyPaper.any_instance.expects(:save).never
        Sidekiq::Client.expects(:enqueue).never

        @worker.process_documents([@document])
      end

      should "update existing invalid papers" do
        uuid = @document["uuid"]
        existing_mendeley_paper = FactoryGirl.create(:mendeley_paper, uuid: uuid)
        existing_mendeley_paper.update_column(:title, nil)
        Sidekiq::Client.expects(:enqueue)
        assert_difference(lambda { SnpReference.count }) do
          @worker.process_documents([@document])
        end
        existing_mendeley_paper.reload
        assert_equal [@snp], existing_mendeley_paper.snps
        assert_equal @document['title'], existing_mendeley_paper.title
      end
    end
  end
end
