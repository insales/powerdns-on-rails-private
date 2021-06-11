ActiveSupport.on_load :action_view do
  # will_paginate сразу и определяет класс и подгружает его в actionview, поэтому приходится наследоваться в колбеке

  class BootstrapLinkRenderer < WillPaginate::ActionView::LinkRenderer
    protected

    def html_container(html)
      tag :nav,
        tag(:ul, html, container_attributes)
    end

    def page_number(page)
      tag :li,
        link(page, page, rel: rel_value(page), class: 'page-link'),
        class: [
          'page-item',
          ('active' if page == current_page)
        ].compact.join(' ')
    end

    def previous_or_next_page(page, text, classname)
      classname << ' page-item'
      tag :li,
        link(text, page || '#', class: 'page-link'),
        :class => [classname[0..3], classname, ('disabled' unless page)].join(' ')
    end
    def gap
      tag :li, link(super, '#', class: 'page-link'), class: 'page-item disabled'
    end
  end
end
