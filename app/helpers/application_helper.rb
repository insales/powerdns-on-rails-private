# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  # Outputs a page title with +@page_title+ appended
  def page_title
    title = t(:layout_main_title)
    title << ' - ' + @page_title unless @page_title.nil?
    title
  end

  # Output the flashes if they exist
  def show_flash
    html = ''
    [ :alert, :notice, :info, :warning, :error ].each do |f|
      options = { :id => "flash-#{f}", :class => "flash-#{f}" }
      options.merge!( :style => 'display:none' ) if flash[f].nil?
      html << content_tag( 'div', options ) { flash[f] || '' }
    end
    html.html_safe
  end

  # Link to Zytrax
  def dns_book( text, link )
    link_to text, "http://www.zytrax.com/books/dns/#{link}", :target => '_blank'
  end

  # Add a cancel link for shared forms. Looks at the provided object and either
  # creates a link to the index or show actions.
  def link_to_cancel( object )
    path = object.class.name.tableize
    path = if object.new_record?
             send( path.pluralize + '_path' )
           else
             send( path.singularize + '_path', object )
           end
    link_to "Cancel", path
  end

  def help_icon( dom_id )
    image_tag('help.png', :id => "help-icn-#{dom_id}", :class => 'help-icn', "data-help" => dom_id )
  end

  def info_icon( image, dom_id )
    image_tag( image , :id => "help-icn-#{dom_id}", :class => 'help-icn', "data-help" => dom_id )
  end

  def link_to_function(name, function, html_options={})
    # forward-port from rails 4
    # TODO: переделать UI на Unobtrusive JavaScript

    onclick = "#{"#{html_options[:onclick]}; " if html_options[:onclick]}#{function}; return false;"
    href = html_options[:href] || '#'

    content_tag(:a, name, html_options.merge(:href => href, :onclick => onclick))
  end

  def error_messages_for(object)
    count = object.errors.count
    return if count.zero?

    html = { id: 'errorExplanation', class: 'errorExplanation' }
    object_name = object.class.name

    I18n.with_options scope: [:activerecord, :errors, :template] do |locale|
      header_message = locale.t :header, count: count, model: object_name.to_s.gsub('_', ' ')

      error_messages = object.errors.full_messages.map do |msg|
        content_tag(:li, msg)
      end.join.html_safe

      contents = ''
      contents << content_tag(:h2, header_message) unless header_message.blank?
      contents << content_tag(:ul, error_messages)

      content_tag(:div, contents.html_safe, html)
    end
  end
end
