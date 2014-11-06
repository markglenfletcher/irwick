require 'test_helper'

class WikipediaPluginTest < Minitest::Test
  def test_detect_the_correct_trigger
    plugin = WikipediaPlugin.new
    trigger_message = mock('message')
    trigger_message.expects(:message).returns('!wiki wikipedia')
    plugin.expects(:respond_to_trigger).with('wikipedia')

    plugin.on_privmsg_messages(trigger_message)
  end

  def test_respond_to_trigger_calls_wiki_api
    plugin = WikipediaPlugin.new
    query = 'wikipedia'
    query_result = 'wikipedia response'
    WikipediaCall.expects(:query).with('wikipedia').returns(query_result)

    assert_equal plugin.respond_to_trigger(query), query_result
  end
end