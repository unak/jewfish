require "jewfish/page"

module Jewfish
  class AutoIndex < Page
    def initialize(src, path)
      super(nil, path)

      @src = src.dup
      @path = path.dup
      @params = {
        'layout' => 'default',
        'title' => File.basename(File.dirname(path)).capitalize,
      }
      @content = <<-EOC
# <%= @title %>
<% Dir.glob(File.join(@dir, '*')).sort.each do |dir| %>
<%  if File.directory?(dir) && File.basename(dir)[0] != '_' %>
* [<%= File.basename(dir) %>](<%= File.join(File.dirname(@path), File.basename(dir)) + '/' %>)
<%   end %>
<% end %>
<% Dir.glob(File.join(@dir, '_posts', '*.md')).sort_by{|e| -File.mtime(e).to_i}.each do |md| %>
<%  entry = Jewfish::Page.new(md, File.basename(md, '.md') + '.html') %>
* [<%= entry['title'] %>](<%= entry.path %>)
<% end %>
      EOC
    end
  end
end
