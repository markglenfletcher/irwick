require 'json'
require 'socket'
require 'thread'

require_relative 'lib/irc_bot'

#load plugins
Dir["#{File.dirname(__FILE__)}/plugins/*_plugin.rb"].each { |f| require f }

def load_config
  rebuilt_hash = {}
  JSON.load(File.open('irc_config.json')).each do |k,v|
    rebuilt_hash[k.to_sym] = v 
  end
  rebuilt_remotes = []
  rebuilt_hash[:remote_servers].each do |h|
    s_hash = {}
    h.each do |k,v|
      s_hash[k.to_sym] = v
    end
    rebuilt_remotes << s_hash
  end
  rebuilt_hash[:remote_servers] = rebuilt_remotes
  rebuilt_hash
end

config = load_config

config[:remote_servers].each do |remote_server|
  local_config = config.clone
  remote_server_config = local_config.merge(remote_server)
  remote_server_config.delete(:remote_servers)

  puts remote_server_config

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

gets