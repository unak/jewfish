require "jewfish/command"

module Jewfish
  class Help < Command
    desc "Show the help of jewfish."
    usage "help [subcommand]"

    def initialize(subcmd = nil)
      if subcmd
        subcmd = @@synonims[subcmd.to_sym].to_s if @@synonims[subcmd.to_sym]
        lib = File.join(File.dirname(__FILE__), subcmd + ".rb")
        unless File.exist?(lib)
          $stderr.puts "#{subcmd}: unknown subcommand."
          exit 1
        end
        require lib
        mod = Jewfish.const_get(subcmd.capitalize)
        mod.show_desc
        puts
        mod.show_usage
        mod.show_longdesc
      else
        puts "Usage: jewfish <subcommand> [<parameters>]"
        puts
        puts "If you want to read the help of a subcommand, type 'jewfish help <subcommand>'."
        puts
        puts "Avairable subcommands:"

        Dir.glob(File.join(File.dirname(__FILE__), '*.rb')).sort.each do |lib|
          require lib
          cmd = File.basename(lib, '.rb')
          mod = Jewfish.const_get(cmd.capitalize)
          puts "  #{mod.synonims}"
        end
      end
    end
  end
end
