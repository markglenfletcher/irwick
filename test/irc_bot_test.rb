require_relative 'test_helper'

class IrcBotTest < Minitest::Test
  def setup
    @socket = mock('socket')

    @irc_message = MockMessage.new
    @irc_message.stubs(type: :PRIVMSG, method_symbol: "on_privmsg_messages")

    @plugin = MockPlugin.new
    @plugin_responses = ['RESPONSE1', 'RESPONSE2']
  end

  def test_instantiates_plugin
    plugin = Minitest::Mock.new
    MockPlugin.expects(:new).returns(plugin)
    bot = IrcBot.new(@socket, plugins: ['MockPlugin'])
    plugin.verify
    assert_equal 1, bot.plugins.count
  end

  def test_raises_argument_error_if_plugin_isnt_valid
    assert_raises ArgumentError do
      IrcBot.new(@socket, plugins: ['MockInvalidPlugin'])
    end
  end

  def test_sends_the_correct_messages_for_type
    @plugin.expects(:on_all_messages).with(@irc_message)
    @plugin.expects(:on_privmsg_messages).with(@irc_message)

    bot = IrcBot.new(@socket)
    bot.plugins << @plugin

    bot.notify_plugins(@irc_message)
  end

  def test_collates_plugin_responses
    @plugin.stubs(:on_all_messages).returns(@plugin_responses[0])
    plugin_2 = MockPlugin.new
    plugin_2.stubs(:on_privmsg_messages).returns(@plugin_responses[1])

    bot = IrcBot.new(@socket)
    bot.plugins = [@plugin, plugin_2]

    assert_equal @plugin_responses, bot.notify_plugins(@irc_message)
  end

  def test_handles_plugin_expections
    exception = Exception.new('Test Exception')

    @plugin.stubs(:on_all_messages).returns(@plugin_responses[0])
    @plugin.stubs(:on_privmsg_messages).raises(exception)

    bot = IrcBot.new(@socket)
    bot.plugins << @plugin

    assert_equal [@plugin_responses[0], exception], bot.notify_plugins(@irc_message)
  end

  def test_handles_irc_message_from_plugin
    message = PongMessage.new(:server => 'server')

    bot = IrcBot.new(@socket)
    bot.expects(:write_to_server).with(message)

    bot.handle_responses [message]
  end

  def test_handles_string_message_from_plugin
    message = 'PONG :server'

    bot = IrcBot.new(@socket)
    bot.expects(:write_to_server).with(message)

    bot.handle_responses [message]
  end

  def test_handles_control_message_from_plugin
    message = ControlMessage.new(:disconnect)

    bot = IrcBot.new(@socket)
    bot.expects(:execute_control_message).with(message)

    bot.handle_responses [message]
  end

  def test_executes_the_correct_function_from_control_message
    message = ControlMessage.new(:disconnect)

    bot = IrcBot.new(@socket)
    bot.expects(:disconnect)

    bot.execute_control_message message
  end

  def test_execute_control_message_handles_absent_control_method
    message = ControlMessage.new(:non_existant_ctrl_method)
    bot = IrcBot.new(@socket)
    bot.execute_control_message message
  end

  def test_bot_terminates_with_false_reload_flag_when_disconnected
    @socket.expects(:write).with('QUIT')
    @socket.expects(:connect)
    @socket.expects(:disconnect)
    irc_bot = IrcBot.new(@socket)

    irc_bot.send(:disconnect)

    assert_equal false, irc_bot.start
  end

  def test_bot_terminates_with_true_reload_flag_when_reloaded
    @socket.expects(:write).with('QUIT')
    @socket.expects(:connect)
    @socket.expects(:disconnect)
    irc_bot = IrcBot.new(@socket)

    irc_bot.send(:reload)

    assert_equal true, irc_bot.start
  end

  def test_bot_shutsdown_gracefully
    irc_bot = IrcBot.new(@socket)
    @socket.expects(:connect)
    @socket.expects(:disconnect)

    irc_bot.send(:disconnect)
    irc_bot.expects(:write_to_server).with('QUIT')

    irc_bot.start
  end
end

class MockPlugin < IrcPlugin
  def on_all_messages(message); nil; end
  def on_privmsg_messages(message); nil; end
end

class MockInvalidPlugin
end

class MockMessage
  attr_reader :type
end
