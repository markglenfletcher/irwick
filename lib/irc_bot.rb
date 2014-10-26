require_relative 'irc_plugin'
require_relative 'irc_message'

class IrcBot
	attr_reader :socket
	attr_accessor :plugins

	def initialize(socket, options = {})
		@termination_trigger = 'catstack'
		@socket = socket
		@plugins = []
		options[:plugins].each do |plugin|
			plugin_class = IrcPlugin.valid_plugin?(plugin)
			raise ArgumentError.new('All plugins must be a subclass of IrcPlugin') unless plugin_class
			@plugins << plugin_class.new(options)
		end if options[:plugins]
	end

	def start
		while (raw_message = @socket.gets)
			message = IrcMessage.new raw_message
			plugin_responses = notify_plugins message
			plugin_responses.each { |response| write_to_socket(response) }
			break if plugin_responses.include?(@termination_trigger)
		end
	end

	def notify_plugins(message)
		plugins.map do |plugin|
			notify_plugin plugin, message
		end.flatten
	end

	private

	def notify_plugin(plugin, message)
		callbacks = [
			plugin.method(:on_all_messages), 
			plugin.method(message.method_symbol.to_sym)
		]
		callbacks.map do |callback|
			begin
				response = callback.call(message)
				response
			rescue Exception => e
				e
			end
		end.compact
	end

	def write_to_socket(response)
		puts "[LOG][WRITE] #{response}"
		@socket.puts response
	end
end