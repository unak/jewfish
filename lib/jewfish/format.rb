module Jewfish
  class UnknownFormat < RuntimeError; end

  class Format
    @@formats = {}

    def self.extension(ext)
      @@formats[ext] = self
    end

    def self.convert(content, ext)
      formatter = @@formats[ext]
      raise UnknownFormat, "unknown format for ``#{ext}''" unless formatter
      formatter.convert(content)
    end

    def self.output_filename(path)
      dir = File.dirname(path)
      dir = File.dirname(dir) if %r'/_posts\z' =~ dir
      file = File.basename(path)
      exts = []
      file.split(/(?=\.)/)[1..-1].reverse_each do |ext|
        break if !@@formats[ext] && ext != '.erb' # .erb is special
        exts.unshift(ext)
      end
      file = file[0..-(exts.join.length + 1)]
      file << '.html' unless /\./ =~ file
      File.join(dir, file).sub(%r'/(\d{4})-(\d{2})-(\d{2})-([^/]+)(\.[^\.]+)$', '/\\1/\\2/\\3/\\4/index\\5')
    end

    Dir.glob(File.join(File.dirname(__FILE__), 'formats', '*.rb')) do |file|
      require file
    end
  end
end
