# frozen_string_literal: true
module ApplicationHelper
  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == 'asc' ? 'desc' : 'asc'
    link_to title, { sort: column, direction: direction }, class: css_class
  end

  def page_navigation_links(pages)
    will_paginate(pages, renderer: BootstrapPagination::Rails,
                         previous_label: '&larr;'.html_safe,
                         next_label: '&rarr;'.html_safe,
                         page_links: false)
  end

  def table_row_sequence_number(paginated, current_page_index)
    paginated.per_page * (paginated.current_page - 1) + current_page_index + 1
  end
end
