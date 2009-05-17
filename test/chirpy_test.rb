require 'test_helper'

class ChirpyTest < Test::Unit::TestCase
  @root = "http://twitter.com/"
  
  context "Class methods" do
    should "request the public timeline URL" do
      assert_equal @root + "statuses/public_timeline.xml", Chirpy.public_timeline.url
    end
    
    should "request the test URL" do
      assert_equal @root + "help/test.xml", Chirpy.test.url
    end
    
    should "request a search URL" do
      search_term = 'three blind mice'
      assert_equal "http://search.twitter.com/search.atom?q=" + CGI.escape(search_term), Chirpy.search(search_term).url
    end
  end
  
  context "Authenticated user" do
    setup do
      @username = 'testuser'
      @password = 'testpass'
      @chirpy   = Chirpy.new(@username, @password)
    end
    
    should "send authentication in URL" do
      assert_equal "https://#{@username}:#{@password}@twitter.com/statuses/user_timeline.xml", @chirpy.user_timeline.url
    end
    
    should "not send authentication in URL when specified" do
      assert_equal "http://twitter.com/statuses/user_timeline.xml", @chirpy.user_timeline(:authenticate => false).url
    end
  end
end
