require 'test_helper'
require 'net/http'

class WikipediaPluginTest < Minitest::Test
  def setup
    @wikipedia_call = mock('wiki_call')
  end

  def test_detect_the_correct_trigger
    plugin = WikipediaPlugin.new(:wikipedia_call => @wikipedia_call)
    plugin.expects(:respond_to_trigger).with('wikipedia').returns('wikipedia')

    trigger_message = mock('message')
    trigger_message.expects(:message).returns('!wiki wikipedia')
    trigger_message.expects(:recipient).returns('#channel')

    plugin.on_privmsg_messages(trigger_message)
  end

  def test_respond_to_trigger_calls_wiki_api
    query = 'wikipedia'
    query_result = 'wikipedia response'
    @wikipedia_call.expects(:query).with('wikipedia').returns(query_result)
    plugin = WikipediaPlugin.new(:wikipedia_call => @wikipedia_call)

    assert_equal plugin.respond_to_trigger(query), query_result
  end
end

class WikipediaCallTest < Minitest::Test
  def setup
    @wikipedia_call = WikipediaCall.new
    @json_response = <<-EOF
      {
          "query": {
              "pages": {
                  "3850": {
                      "pageid": 3850,
                      "ns": 0,
                      "title": "Baseball",
                      "extract": "<p><b>Baseball</b>"
                  }
              }
          }
      }
    EOF
    @json_response.strip!
    @expected_result = 'Baseball'
    @uri = URI('http://en.wikipedia.org/w/api.php?action=query&prop=extracts&format=json&exintro=&titles=Baseball')
  end

  def test_build_uri_is_as_expected
    assert_equal @wikipedia_call.build_uri_for('Baseball'), @uri
  end

  def test_query_calls_api
    Net::HTTP.expects(:get).with(@uri).returns(@json_response)
    @wikipedia_call.query('Baseball')
  end

  def test_query_fails_is_handled
    Net::HTTP.expects(:get).with(@uri).raises(Exception)
    assert_equal "Can't do it!", @wikipedia_call.query('Baseball')
  end

  def test_query_returns_correct_string_upon_success
    Net::HTTP.expects(:get).with(@uri).returns(@json_response)
    assert_equal @expected_result, @wikipedia_call.query('Baseball')
  end

  def test_dissect_json_pulls_out_extracts
    assert_equal @expected_result, @wikipedia_call.dissect_json(@json_response)
  end

  def test_query_handles_keyerror
    Net::HTTP.expects(:get).with(@uri).returns(@json_response)
    @wikipedia_call.expects(:dissect_json).with(@json_response).raises(KeyError)
    assert_equal 'Could not parse the JSON response from Wikipedia', @wikipedia_call.query('Baseball')
  end
end