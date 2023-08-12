# frozen_string_literal: true

class NewsControllerTest < ActionController::TestCase
  should "index be shown" do
    get(:index)
  end
end

