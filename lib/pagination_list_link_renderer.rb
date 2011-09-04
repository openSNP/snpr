class PaginationListLinkRenderer < WillPaginate::ViewHelpers::LinkRenderer

  protected
	def gap
	  #tag(:li, link("…","#"), :class => "disabled")
	  '<li class="disabled"><a href="#">...</a></li>'
	end

    def page_number(page)
      unless page == current_page
        tag(:li, link(page, page, :rel => rel_value(page)))
      else
        tag(:li, link(page, '#'), :class => "disabled")
      end
    end

    def previous_or_next_page(page, text, classname)
	  if text == "&#8592; Previous"  
		text = "&larr; Previous"
	  end

	  if text == "Next &#8594;"
		text = "Next &rarr;"
	  end

	  if classname == "previous_page"
		  classname = "prev"
	  end

	  if classname == "next_page"
		  classname = "next"
	  end

      if page
		tag(:li, link(text, page), :class => classname)
      else
        	tag(:li, link(text, '#'), :class => classname + ' disabled')
      end
    end


    def html_container(html)
      tag(:ul, html, container_attributes)
    end
end
