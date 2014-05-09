require "jewfish/command"
require "jewfish/page"
require "webrick"

module Jewfish
  class Start < Command
    desc "Start your webserver."
    usage "start <source directory> [options]"
    longdesc <<-EOD
options:
  --Port=<port>            listen port (default: 3000)
  --BindAddress=<address>  bind address (default: 0.0.0.0)
  --MaxClients=<num>       num of max clients (default: 4)
  --RequestTimeout=<sec>   request timeout (default: 30)
  --DoNotReverseLookup     do not reverse lookup (default: false)
    EOD

    def initialize(srcdir, *opts)
      tmp = parse_options(opts)
      opts = {}
      opts[:Port] = (tmp.delete(:Port) || 3000).to_i
      opts[:BindAddress] = tmp.delete(:BindAddress) || "0.0.0.0"
      opts[:MaxClients] = (tmp.delete(:MaxClients) || 4).to_i
      opts[:RequestTimeout] = (tmp.delete(:RequestTimeout) || 30).to_i
      opts[:DoNotReverseLookup] = tmp.delete(:DoNotReverseLookup)
      raise "Invalid parameter(s): #{tmp.keys.join(', ')}" unless tmp.empty?

      server = WEBrick::HTTPServer.new(opts)

      shut = proc {server.shutdown}
      siglist = %w"TERM QUIT"
      siglist << %w"HUP INT" if $stdin.tty?
      siglist &= Signal.list.keys
      siglist.each do |sig|
        Signal.trap(sig, shut)
      end

      server.mount_proc('/') do |req, res|
        path = req.path.dup
        path = File.join(path, 'index.html') if File.directory?(File.join(srcdir, path))
        if File.exist?(src = File.join(srcdir, path)) ||
           File.exist?(src = File.join(srcdir, File.dirname(path), File.basename(path, '.*') + '.md')) ||
           File.exist?(src = File.join(srcdir, File.dirname(path), File.basename(path, '.*') + '.md.erb')) ||
           File.exist?(src = File.join(srcdir, File.dirname(path), File.basename(path) + '.erb')) ||
           File.exist?(src = File.join(srcdir, File.dirname(path), '_posts', File.basename(path, '.*') + '.md'))
            res.body = Page.convert(src, path)
        elsif File.directory?(File.join(srcdir, req.path, '_posts'))
          page = Page.new(nil, path)
          page.src = File.join(srcdir, File.dirname(path), 'index.md.erb')
          page.params['layout'] = 'page'
          page.params['title'] = File.basename(req.path).capitalize
          page.content = <<-EOC
# <%= @title %>
<% Dir.glob(File.join(@dir, '_posts', '*.md')).sort_by{|e| -File.mtime(e).to_i}.each do |md| %>
<%  entry = Jewfish::Page.new(md, File.join(File.dirname(@path), File.basename(md, '.md') + '.html')) %>
* [<%= entry['title'] %>](<%= entry.path %>)
<% end %>
          EOC
          res.body = page.convert
        else
          raise WEBrick::HTTPStatus::NotFound, path
        end
        res.content_type = WEBrick::HTTPUtils.mime_type(path, WEBrick::HTTPUtils::DefaultMimeTypes)
        if res.content_type == "text/html"
          res.content_type << "; charset=utf-8"
        end
      end

      server.start
    end
  end
end
