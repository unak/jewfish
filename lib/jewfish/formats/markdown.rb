require "jewfish/format"
require "kramdown"

module Jewfish
  class Markdown < Format
    extension '.md'

    def self.convert(content)
      Kramdown::Document.new(content.force_encoding('utf-8')).to_html
    end
  end
end
