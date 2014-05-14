require "jewfish/auto_index"
require "jewfish/command"
require "jewfish/format"
require "jewfish/page"

module Jewfish
  class Generate < Command
    desc "Generate your website."
    usage "generate <source directory> [options]"
    longdesc <<-EOD
options:
  --out=<dir>  specify output directory (default: _out)
    EOD

    def initialize(srcdir, *opts)
      tmp = parse_options(opts)
      opts = {}
      opts[:out] = tmp.delete(:out) || "_out"
      raise "Invalid parameter(s): #{tmp.keys.join(', ')}" unless tmp.empty?

      Dir.glob(File.join(srcdir, '**', '*.{html,md,erb}')).each do |src|
        next if %r'/(_.*?)/' =~ src && $1 != '_posts'
        path = Format.output_filename(src)[srcdir.size..-1]
        content = Page.convert(src, path)
        out = File.join(opts[:out], path)
        mkdir_p(File.dirname(out)) unless File.exist?(File.dirname(out))
        File.open(out, 'wb') do |f|
          f.print content
        end

        if %r'/_posts/' =~ src
          index = File.join(opts[:out], $`[srcdir.size..-1], 'index.html')
          content = AutoIndex.convert(File.join($`, 'index.md.erb'), $`[srcdir.size..-1])
          File.open(index, 'wb') do |f|
            f.print content
          end
        end
      end
    end

    def mkdir_p(dir)
      cur = nil
      dir.split(%r'/').each do |d|
        cur = cur ? File.join(cur, d) : d
        Dir.mkdir(cur) unless File.exist?(cur)
      end
    end
  end
end
