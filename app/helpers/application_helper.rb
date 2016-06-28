module ApplicationHelper
  def markdown(body)
    renderer = Redcarpet::Render::HTML.new(filter_html: true)
    markdown = Redcarpet::Markdown.new(renderer,  tables: true, autolink: true)
    markdown.render(body).html_safe
  end
end
