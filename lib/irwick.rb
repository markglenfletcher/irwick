require 'json'
require 'socket'
require 'thread'
require 'irwick/irc_bot'
require 'irwick/irc_config'
require 'irwick/irc_plugin'
require 'irwick/irc_message'
require 'irwick/control_message'
Gem.find_files("irwick/plugins/*_plugin.rb").each { |path| require path }