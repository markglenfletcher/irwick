require_relative '../lib/irc_plugin'

class ToolsPlugin < IrcPlugin
  attr_reader :registered, :sent_registration

  def initialize(options = {})
    @options = options
    @registered = false
    @sent_registration = false
    @connected = false
  end

  def on_notice_messages(message)
    respond_with_registration unless @sent_registration
  end

  def on_ping_messages(message)
    pong_message message.server
  end

  # Handle registration message
  def on_001_messages(message)
    @registered = true
    @options[:channels].map { |channel| join_channel(channel) }
  end

  # Handle nickname taken
  def on_462_messages(message)
    UserMessage.new(:nickname => @options[:second_nick_name], :mode => '8', :realname => @options[:real_name])
  end

  private

  def respond_with_registration
    @sent_registration = true
    [
      PassMessage.new(:password => @options[:pass]),
      NickMessage.new(:nickname => @options[:nick_name]),
      UserMessage.new(:nickname => @options[:nick_name], :mode => '8', :realname => @options[:real_name])
    ]
  end

  def join_channel(channel_name)
    JoinMessage.new(:channel => channel_name)
  end

  def pong_message(server)
    PongMessage.new(:server => server)
  end
end