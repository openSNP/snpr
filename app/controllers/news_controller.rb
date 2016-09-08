class NewsController < ApplicationController

  def index

  end

  def paper_rss
    @newest_plos_paper = PlosPaper.order('created_at DESC').limit(20)
    @newest_mendeley_paper = MendeleyPaper.order('created_at DESC').limit(20)

    @newest_paper = @newest_mendeley_paper | @newest_plos_paper
    @newest_paper.sort! { |a,b| b.created_at <=> a.created_at }

    render :action => 'paper_rss', :layout => false
  end

end
