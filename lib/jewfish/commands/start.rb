require "jewfish/auto_index"
require "jewfish/command"
require "jewfish/format"
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

    attr_reader :server

    def initialize(srcdir, *opts)
      srcdir = File.expand_path(srcdir)
      tmp = parse_options(opts)
      opts = {}
      opts[:Port] = (tmp.delete(:Port) || 3000).to_i
      opts[:BindAddress] = tmp.delete(:BindAddress) || "0.0.0.0"
      opts[:MaxClients] = (tmp.delete(:MaxClients) || 4).to_i
      opts[:RequestTimeout] = (tmp.delete(:RequestTimeout) || 30).to_i
      opts[:DoNotReverseLookup] = tmp.delete(:DoNotReverseLookup)
      detach = tmp.delete(:Detach)
      logger = tmp.delete(:Logger)
      if logger
        opts[:Logger] = WEBrick::Log.new(logger)
        opts[:AccessLog] = [[opts[:Logger], WEBrick::AccessLog::COMMON_LOG_FORMAT]]
      end
      raise "Invalid parameter(s): #{tmp.keys.join(', ')}" unless tmp.empty?

      @server = WEBrick::HTTPServer.new(opts)

      shut = proc {@server.shutdown}
      siglist = %w"TERM QUIT"
      siglist << %w"HUP INT" if $stdin.tty?
      siglist &= Signal.list.keys
      siglist.each do |sig|
        Signal.trap(sig, shut)
      end

      @server.mount_proc('/') do |req, res|
        path = req.path.dup
        if File.directory?(File.join(srcdir, path)) || path[-1] == '/'
          if path[-1] != '/'
            res.set_redirect WEBrick::HTTPStatus::MovedPermanently, path + '/'
            break
          end
          path = File.join(path, 'index.html')
        end

        src = File.join(srcdir, path)
        found = false
        Dir.glob([File.join(srcdir, path.sub(%r'\.[^/]*\z', '') + '.*'), File.join(srcdir, File.dirname(path), '_posts', File.basename(path, '.*') + '.*'), File.join(srcdir, File.dirname(path.sub(%r'/\d{4}/\d{2}/\d{2}/[^/]+/', '/')), '_posts', File.basename(path.sub(%r'/(\d{4})/(\d{2})/(\d{2})/([^/]+)/index', '/\\1-\\2-\\3-\\4'), '.*') + '.*')]) do |file|
          if Format.output_filename(file) == src
            res.body = Page.convert(file, path)
            found = true
            break
          end
        end
        unless found
          if %r'/index\.html\z' =~ path && !Dir.glob([File.join(srcdir, File.dirname(path), '**', '_posts'), File.join(srcdir, File.dirname(path), '*.{html,md,md.erb}')]).empty?
            res.body = AutoIndex.convert(File.join(srcdir, File.dirname(path), 'index.md.erb'), path)
          else
            raise WEBrick::HTTPStatus::NotFound, path
          end
        end

        res.content_type = WEBrick::HTTPUtils.mime_type(path, WEBrick::HTTPUtils::DefaultMimeTypes)
        if res.content_type == "text/html"
          res.content_type << "; charset=utf-8"
        end
      end

      if detach
        Thread.new do
          @server.start
        end
        sleep 0.1
      else
        @server.start
      end
    end
  end
end
