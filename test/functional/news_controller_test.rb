# encoding: utf-8

class NewsControllerTest < ActionController::TestCase
  should 'index be shown' do
    get(:index)
  end
end
