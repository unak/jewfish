require "erb"
require "jewfish/format"
require "yaml"

module Jewfish
  class Page
    def self.convert(src, path, content: nil, params: {})
      page = self.new(src, path)
      page.convert(content, params)
    end

    attr_accessor :src, :path, :content, :plain, :params

    def initialize(src, path)
      @src = src.dup if src
      @path = path.dup
      @path.sub!(/(?=^|\/)(\d{4})-(\d{2})-(\d{2})-([^\/]+)(\.[^\.]+)$/, '\\1/\\2/\\3/\\4/index\\5')
      @content = @plain = File.binread(src) if src
      if /\A---\r?\n/ =~ @plain
        @params = YAML.load(@plain)
        @content = @plain.sub(/\A---$.*?^---$\s*/m, '')
      else
        @params = {}
      end
    end

    def to_s
      @content
    end

    def [](key)
      @params[key]
    end

    def convert(content = nil, params = {})
      File.basename(src).split(/(?=\.)/)[1..-1].reverse_each do |ext|
        if ext == '.erb'
          erb(content, params)
        else
          begin
            @content = Format.convert(@content, ext)
          rescue Jewfish::UnknownFormat
            break
          end
        end
      end
      apply_layout
      to_s
    end

    def convert_md
      @content = Kramdown::Document.new(@content.force_encoding('utf-8')).to_html
    end

    def erb(content = nil, params = {})
      params = @params.merge(params)
      erb = ERB.new(@content, nil, '<>', '_' + @src.gsub(/\W/, '_'))
      mod = erb.def_module
      obj = Object.new
      obj.extend(mod)
      params.each_pair do |k, v|
        obj.instance_variable_set("@#{k}".to_sym, v)
      end
      obj.instance_variable_set(:@dir, File.dirname(@src))
      obj.instance_variable_set(:@path, @path)
      @content = obj.erb{content}
    end

    def apply_layout
      if @params["layout"] && @params["layout"] != "nil"
        dir = File.dirname(@src)
        applied = false
        while dir != File.dirname(dir)
          if File.directory?(File.join(dir, "_layouts"))
            if File.exist?(layout = File.join(dir, "_layouts", @params["layout"] + ".html.erb"))
              @content = Page.convert(layout, @path, content: @content, params: @params)
              applied = true
              break
            end
          end
          dir = File.dirname(dir)
        end
        warn "layout '#{@params['layout']}' is not found" unless applied
      end
    end
  end
end
