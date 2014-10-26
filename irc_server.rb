require 'socket'

server = TCPServer.open(20002)
puts 'Waiting for connections...'

loop do
	client = server.accept
	begin
		puts client.class
		puts client.inspect
		puts '######'
		client.puts 'Connection establised'
		client.puts "Time is now #{Time.now}"
		client.puts 'Terminating connection'
	ensure
		client.close
	end
end