require_relative 'test_helper'

class IrcBotTest < Minitest::Test
	def setup
		@socket = Minitest::Mock.new

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
