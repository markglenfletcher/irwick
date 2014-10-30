require 'json'
require 'socket'
require 'thread'

require_relative 'lib/irc_bot'
require_relative 'lib/irc_config'

#load plugins
Dir["#{File.dirname(__FILE__)}/plugins/*_plugin.rb"].each { |f| require f }

# load config
config_from_file  = JSON.parse(IO.read('irc_config.json'), :symbolize_names => true)

irc_config = IrcConfig.new(config_from_file)

# create a socket and spin up a new thread for each irc_server
irc_config.remote_servers.each do |remote_server|
  remote_server_config = irc_config.to_hash.merge(remote_server.to_h)
  remote_server_config.delete(:remote_servers)

  Thread.new do
    socket = TCPSocket.new(remote_server[:server_address], remote_server[:port])
    begin
      bot = IrcBot.new(socket, remote_server_config)
      bot.start
    ensure
      puts "[LOGLOG] Socket closed"
      socket.close
    end 
  end
end

# Wait forever
gets