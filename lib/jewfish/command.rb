module Jewfish
  class Command
    @@synonims = {
      run: :start
    }

    class << self
      def run(*args)
        cmd = args.shift || 'help'
        cmd = @@synonims[cmd.to_sym].to_s if @@synonims[cmd.to_sym]
        lib = File.join(File.dirname(__FILE__), 'commands', cmd + '.rb')
        raise "unknown subcommand: #{cmd}" unless File.exist?(lib)
        require lib
        mod = Jewfish.const_get(cmd.capitalize)
        if args.size < mod.req || (!mod.rest && args.size > mod.req + mod.opt)
          $stderr.puts "jewfish: not enough or too many parameters."
          $stderr.puts
          mod.show_usage($stderr)
          exit 1
        end

        mod.new(*args)
      end

      def show_desc(io = $stdout)
        io.puts "#{synonims}: #{@desc}"
      end

      def show_longdesc(io = $stdout)
        return unless @longdesc
        io.puts
        io.puts @longdesc
      end

      def show_usage(io = $stdout)
        io.puts "Usage: jewfish #{@usage}"
      end

      def req
        reqs = instance_method(:initialize).parameters.find{|e| e.first == :req}
        reqs ? reqs.size - 1 : 0
      end

      def opt
        opts = instance_method(:initialize).parameters.find{|e| e.first == :opt}
        opts ? opts.size - 1 : 0
      end

      def rest
        instance_method(:initialize).parameters.find{|e| e.first == :rest}
      end

      def synonims
        name = self.name.to_s.sub(/.*::/, '').downcase
        syns = @@synonims.select{|k, v| v.to_s == name}.map{|k, v| k.to_s}
        name << " (#{syns.join(', ')})" unless syns.empty?
        name
      end

      private
      def desc(str)
        @desc = str
      end

      def longdesc(str)
        @longdesc = str
      end

      def usage(str)
        @usage = str
      end
    end

    def parse_options(args)
      opts = {}
      args.each do |arg|
        unless /\A--(.*?)(?:(?:\s+|=)(.*))?$/ =~ arg
          raise "Invalid parameter: #{arg}"
        end
        opts[$1.to_sym] = $2 || true
      end
      opts
    end
  end
end
