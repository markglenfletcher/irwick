class ConsoleLoggerPlugin < IrcPlugin
	def initialize(options = {})
		@server_ref = options[:server_ref]
	end

	def on_all_messages(message)
		puts "[#{@server_ref}][#{message.type.to_s}] #{message.raw_message}"
	end
end