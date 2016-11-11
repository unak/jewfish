require "test/unit"
require "jewfish/commands/help"

class TestHelp < Test::Unit::TestCase
  def redirect
    r, w = IO.pipe
    begin
      oldout = $stdout.dup
      olderr = $stderr.dup
      $stdout.reopen(w)
      $stderr.reopen(w)
      yield
    ensure
      $stderr.reopen(olderr) if olderr
      $stdout.reopen(oldout) if oldout
      w.close
    end
    result = r.read
    r.close
    result
  end

  def test_help
    h = redirect do
      Jewfish::Help.new
    end
    assert_match(/\AUsage:/, h)
    assert_match(/^Avairable subcommands:\s*$/, h)

    /^Avairable subcommands:\s*$\s*/ =~ h
    $'.split(/\)?\s+\(?/).each do |subcmd|
      h = redirect do
        Jewfish::Help.new(subcmd)
      end
      assert_match(/\A(?:#{subcmd}(?: \((?:\w+, )*\w+\))?|\w+ \((?:\w+, )*#{subcmd}(?:, \w+)*\)):/, h)
      assert_match(/^Usage:/, h)
    end
  end
end
