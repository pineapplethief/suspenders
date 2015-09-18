module HtmlHelper
  def svg_tag(filename, options = {})
    options[:width], options[:height] = extract_dimensions(options.delete(:size)) if options[:size]

    assets = Rails.application.assets
    file = assets.find_asset(filename + ".svg").body.force_encoding("UTF-8")
    doc = Nokogiri::HTML::DocumentFragment.parse file

    svg = doc.at_css "svg"

    svg["class"] = options[:class] if options[:class]
    svg["id"] = options[:id] if options[:id]
    svg["width"] = options[:width] if options[:width]
    svg["height"] = options[:height] if options[:height]

    raw doc
  end

  def close_button_tag(options = {})
    options = Hash(options).reverse_merge!({type: 'button', class: 'close', aria: {label: 'Close'}})
    content_tag :button, options do
      content_tag :span, aria: {hidden: 'true'} do
        '&times;'.html_safe
      end
    end
  end

  def icon_tag(name)
    content_tag :i, nil, class: "icon icon-#{name}"
  end

  def flash_class(level)
    case level.to_sym
      when :notice then "alert alert-success"
      when :error then "alert alert-danger"
      when :alert then "alert alert-danger"
    end
  end

  def modal_for(id, modal_title = nil, &block)
    modal_id = id + '-modal'
    modal_body = capture(&block)
    render partial: 'common/modal', locals: {modal_id: modal_id,
                                             modal_title: modal_title,
                                             modal_body: modal_body}
  end

  def copyright
    t(:copyright, year: Date.current.year)
  end

end
