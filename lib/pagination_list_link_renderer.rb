class PaginationListLinkRenderer < WillPaginate::ViewHelpers::LinkRenderer

  protected

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

      if page
		  if classname == "previous"
			tag(:li, link(text, page), :class => "prev")
		  else
			tag(:li, link(text, page), :class => "next")
		  end
      else
		  if classname == "Previous"
        	tag(:li, text, :class => 'prev disabled')
		  else if classname == "Next"
			tag(:li, text, :class => 'next disabled')
		  end
		  end
      end
    end

    def html_container(html)
      tag(:ul, html, container_attributes)
    end
end
