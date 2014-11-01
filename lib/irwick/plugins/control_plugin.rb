class ControlPlugin < IrcPlugin
  def initialize(options = {})
    @bot_name = options[:nick_name]
    @bot_key = options[:command_key]
    @owner = options[:owner]
  end

  def valid_command_message?(message)
    control_command = control_command_breakdown(message)
    if control_command &&
     message_from_owner?(message.user) &&
     message_for_me?(control_command[:recipient]) &&
     command_authorised?(control_command[:key])
      control_command[:command] 
    else
      false
    end
  end

  def on_privmsg_messages(message)
    if control_command = valid_command_message?(message)
      ControlMessage.new(control_command.to_sym)
    end
  end

  private

  def message_from_owner?(user)
    (/(?<user>\S+)!\S+/.match(user))[:user] == @owner
  end

  def message_for_me?(recipient)
    recipient == @bot_name
  end

  def command_authorised?(key)
    key == @bot_key
  end

  def control_command_breakdown(command)
    /(?<recipient>\S+) (?<command>\S+) (?<key>\S+)/.match(command.message.chomp)
  end
end