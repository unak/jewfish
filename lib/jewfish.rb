require "jewfish/command"

module Jewfish
  def self.run(*args)
    Command.run(*args)
  end
end
