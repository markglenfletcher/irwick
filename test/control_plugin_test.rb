require_relative 'test_helper'

class ControlPluginTest < Minitest::Test
  def setup
    @options = {
      nick_name: 'swarmhorderrndm',
      second_nick_name: 'swarmhorderrndm2',
      user_name: 'swarmhorderrndm',
      real_name: 'Ruby Bot testing',
      host_name: "8",
      server_name: "*",
      pass: "*",
      owner: 'mfmfmfmfmfmf',
      command_key: '4325642',
      server_ref: 'freenode',
      host_name: 'holmes.freenode.net',
      port: 6667,
      channels: [
        '#web',
        '#ruby'
      ]
    }
    @plugin = ControlPlugin.new @options
  end

  def test_valid_command_message_recognised
    message = mock('message')
    message.expects(:user).returns('mfmfmfmfmfmf!~mfmfmfmfm@31.55.24.2')
    message.expects(:message).returns('swarmhorderrndm reload 4325642')

    assert_equal 'reload', @plugin.valid_command_message?(message)
  end

  def test_invalid_command_message_recognised
    message = mock('message')
    message.expects(:user).returns('mfmfmfmfmfmf!~mfmfmfmfm@31.55.24.2')
    message.expects(:message).returns('swarmhorderrndm reload incorrect_key')

    assert_equal false, @plugin.valid_command_message?(message)
  end

  def test_creates_the_correct_command_message
    message = mock('message')
    message.expects(:user).returns('mfmfmfmfmfmf!~mfmfmfmfm@31.55.24.2')
    message.expects(:message).returns('swarmhorderrndm disconnect 4325642')

    assert_equal :disconnect, @plugin.on_privmsg_messages(message).method
  end

  def test_ignores_other_messages
    message = mock('message')
    message.expects(:message).returns('hi')

    assert_equal nil, @plugin.on_privmsg_messages(message)
  end
end