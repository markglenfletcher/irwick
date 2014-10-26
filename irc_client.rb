require 'socket'

module Commands
	USER_COMMAND = "USER %{user_name} %{host_name} %{server_name} :%{real_name}"
	PASS_COMMAND = "PASS %{secret_pass}"
	NICK_COMMAND = "NICK %{nick}"
	QUIT_COMMAND = "QUIT"

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
end

class IrcClient
	include Commands

	attr_reader :remote_servers, :nick_name, :user_name, :real_name, :host_name, :server_name, :pass
	attr_reader :socket

	def initialize(config = {})
		@remote_servers = config.fetch(:remote_servers)
		@nick_name = config.fetch(:nick_name)
		@user_name = config.fetch(:user_name)
		@real_name = config.fetch(:real_name)
		@host_name = config.fetch(:host_name)
		@server_name = config.fetch(:server_name)
		@pass = config.fetch(:pass)
	end

	def connect
		server = @remote_servers.first
		@socket = TCPSocket.new(server.hostname,
			server.port)
		establish_connection
		begin
			while line = @socket.gets
				status = process_message(line.chomp)
				if status == 'EXIT'
					break
				end
			end
		ensure
			@socket.puts quit_command
			@socket.close
		end
	end

	def establish_connection
		@socket.puts pass_command :secret_pass => pass
		@socket.puts nick_command :nick => nick_name
		@socket.puts user_command :user_name => user_name,
			:host_name => host_name,
			:server_name => server_name,
			:real_name => real_name
	end

	def process_message(message)
		puts message
	end
end

class IrcServer
	attr_reader :hostname, :port

	def initialize(hostname, port)
		@hostname = hostname
		@port = port
	end
end

config = {
	:nick_name => 'swarmhorderrndm',
	:user_name => 'swarmhorderrndm',
	:real_name => 'Ruby Bot testing',
	:host_name => '8',
	:server_name => '*',
	:pass => '*',
	:remote_servers => [
		IrcServer.new('holmes.freenode.net', 6667)
	]
}

client = IrcClient.new(config)
client.connect

