require_relative '../lib/irc_plugin'

class ToolsPlugin < IrcPlugin
  def initialize(options = {})
    @options = options
    @registered = false
    @sent_registration = false
    @connected = false
  end

  def on_notice_messages(message)
    respond_with_registration unless @sent_registration
  end

  def on_001_messages(message)
    @registered = true
    join_channel('#orc_tools')
  end

  private

  def respond_with_registration
    @sent_registration = true
    [
      PassMessage.new(:password => @options[:pass]).to_s,
      NickMessage.new(:nickname => @options[:nick_name]).to_s,
      UserMessage.new(:nickname => @options[:nick_name], :mode => '8', :realname => @options[:real_name]).to_s
    ]
  end

  def join_channel(channel_name)
    JoinMessage.new(:channel => channel_name).to_s
  end
end