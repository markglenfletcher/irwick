require_relative '../lib/irc_plugin'

class ToolsPlugin < IrcPlugin
	attr_reader :options

	USER_COMMAND = "USER %{user_name} %{host_name} %{server_name} :%{real_name}"
	PASS_COMMAND = "PASS %{secret_pass}"
	NICK_COMMAND = "NICK %{nick}"
	QUIT_COMMAND = "QUIT"

	def initialize(options = {})
		@options = options
		@registered = false
		@connected = false
	end

	def on_notice_messages(message)
		respond_with_registration unless @registered
	end

	def on_mode_messages(message)
		respond_to_connected if is_connection_message && !@connected
	end

	def on_ping_messages(message)
		"PONG"
	end

	private

	def user_command(options = {})
		USER_COMMAND % options
	end

	def pass_command(options = {})
		PASS_COMMAND % options
	end

	def nick_command(options = {})
		NICK_COMMAND % options
	end

	def quit_command
		QUIT_COMMAND
	end

	def respond_with_registration
		@registered = true
		[
			pass_command(:secret_pass => options[:pass]),
			nick_command(:nick => options[:nick_name]),
			user_command(:user_name => options[:user_name],
				:host_name => options[:host_name],
				:server_name => options[:server_name],
				:real_name => options[:real_name])
		]
	end

	def is_connection_message?(message)
		(/:rubybottesting MODE rubybottesting :+i/ =~ message).nil?
	end

	def respond_to_connected
		@connected = true
	end
end