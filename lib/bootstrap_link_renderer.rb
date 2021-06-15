ActiveSupport.on_load :action_view do
  # will_paginate сразу и определяет класс и подгружает его в actionview, поэтому приходится наследоваться в колбеке

  class BootstrapLinkRenderer < WillPaginate::ActionView::LinkRenderer
    protected

    def html_container(html)
      tag :nav,
        tag(:ul, html, container_attributes.merge(class: "pagination justify-content-center"))
    end

    def page_number(page)
      tag :li,
        link(page, page, rel: rel_value(page), class: 'page-link'),
        class: [
          'page-item',
          ('d-none d-sm-block' unless page == current_page), # hide on mobiles
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
      tag :li, link(super, '#', class: 'page-link d-none d-sm-block'), class: 'page-item disabled'
    end
  end
end
