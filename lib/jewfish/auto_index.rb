require "jewfish/page"

module Jewfish
  class AutoIndex < Page
    def initialize(src, path)
      super(nil, path)

      @src = src.dup
      @params = {
        'layout' => 'page',
        'title' => File.basename(path).capitalize,
      }
      @content = <<-EOC
# <%= @title %>
<% Dir.glob(File.join(@dir, '_posts', '*.md')).sort_by{|e| -File.mtime(e).to_i}.each do |md| %>
<%  entry = Jewfish::Page.new(md, File.basename(md, '.md') + '.html') %>
* [<%= entry['title'] %>](<%= entry.path %>)
<% end %>
      EOC
    end
  end
end
