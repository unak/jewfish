require "net/http"
require "test/unit"
require "uri"
require "jewfish/commands/start"

class TestStart < Test::Unit::TestCase
  def setup
    @srcdir = File.expand_path("../../sample", File.dirname(__FILE__))
    @server = nil
    @http = nil
    @res = nil
  end

  def teardown
    @http.finish if @http
    @server.shutdown if @server
  end

  def get(path)
    @http ||= Net::HTTP.start('localhost', 3000)
    @res = @http.get(path)
  end

  def assert_response(response)
    response = response.to_s.split(/_/).map{|e| e.capitalize}.join
    assert_kind_of Net.const_get("HTTP#{response}"), @res
  end

  def assert_redirected(path)
    assert_response :redirection
    uri = URI.parse(@res['location'])
    assert_equal 'localhost', uri.host
    assert_equal 3000, uri.port
    assert_equal path, uri.path
  end

  def test_start
    start = Jewfish::Start.new(@srcdir, '--Detach', "--Logger=#{File::NULL}")
    @server = start.server

    get '/'
    assert_response :success

    get '/index.html'
    assert_response :success

    get '/news'
    assert_redirected '/news/'

    get '/news/'
    assert_response :success

    get '/news/index.html'
    assert_response :success

    get '/news/sample1.html'
    assert_response :success

    get '/news/sample2.html'
    assert_response :success

    get '/news/sample3.html'
    assert_response :success

    get '/news/_posts/sample1.html'
    assert_response :not_found

    get '/news/_posts/sample1.md'
    assert_response :not_found
  end
end
