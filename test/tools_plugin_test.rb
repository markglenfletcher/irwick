require_relative 'test_helper'

class ToolsPluginTest < Minitest::Test
  def setup
    @options = {
      nick_name: 'swarmhorderrndm',
      second_nick_name: 'swarmhorderrndm2',
      user_name: 'swarmhorderrndm',
      real_name: 'Ruby Bot testing',
      host_name: "8",
      server_name: "*",
      pass: "*",
      server_ref: 'freenode',
      host_name: 'holmes.freenode.net',
      port: 6667,
      channels: [
        '#web',
        '#ruby'
      ]
    }
    @plugin = ToolsPlugin.new @options
  end

  def test_registered_after_registration_message_received
    registration_received = ':holmes.freenode.net 001 rubybottesting :Welcome to the freenode Internet Relay Chat Network rubybottesting'
    @plugin.on_001_messages registration_received
    assert_equal true, @plugin.registered
  end

  def test_responds_with_registration_when_initial_notice_received
    @plugin.on_notice_messages 'NOTICE AUTH :***'
    assert_equal true, @plugin.sent_registration
  end

  def test_responds_with_correct_registration_messages
    expected_pass_message = 'PASS *'
    expected_nick_message = 'NICK swarmhorderrndm'
    expected_user_message = 'USER swarmhorderrndm 8 * :Ruby Bot testing'
    responses = @plugin.on_notice_messages 'NOTICE AUTH :***'
    assert_equal responses.map(&:to_s), [expected_pass_message, expected_nick_message, expected_user_message]
  end

  def test_joins_channels_after_registration
    registration_received = ':holmes.freenode.net 001 rubybottesting :Welcome to the freenode Internet Relay Chat Network rubybottesting'
    @plugin.expects(:join_channel).with('#web')
    @plugin.expects(:join_channel).with('#ruby')
    @plugin.on_001_messages(registration_received)
  end

  def test_responds_to_pong_messages
    message = mock('message')
    message.expects(:server).returns('server')

    responses = @plugin.on_ping_messages message
    assert_equal 'PONG :server', responses.to_s
  end
end