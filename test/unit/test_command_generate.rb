require "fileutils"
require "test/unit"
require "tmpdir"
require "jewfish/commands/generate"

class TestGenerate < Test::Unit::TestCase
  def setup
    @outdir = File.join(Dir.tmpdir, "test_generate_#{Process.pid}")
    @srcdir = File.expand_path("../../sample", File.dirname(__FILE__))
  end

  def teardown
    FileUtils.rm_rf(@outdir) if File.exist?(@outdir)
  end

  def test_generate
    Jewfish::Generate.new(@srcdir, "--out=#{@outdir}")
    files = Dir.glob(File.join(@outdir, '**', '*.html'))
    assert_includes files, File.join(@outdir, 'index.html')
    assert_includes files, File.join(@outdir, 'news/index.html')
    assert_includes files, File.join(@outdir, 'news/sample1.html')
    assert_includes files, File.join(@outdir, 'news/sample2.html')
    assert_includes files, File.join(@outdir, 'news/sample3.html')
    assert_equal 5, files.size
  end
end
