require 'ostruct'

class IrcMessage < OpenStruct
  attr_reader :validator

  def self.parse(raw_message)
    if matches = validate_message(raw_message)
      attributes = Hash[matches.names.map { |name| [name.to_sym, matches[name.to_sym]] }]
      return attributes.merge(:type => matches[:type].downcase.to_sym, :raw_message => raw_message)
    else
      return {:type => :unknown, :raw_message => raw_message}
    end
  end

  def self.message_matches(message_regexp, message)
    matcher_type = Object.const_get("IrcMessageTypes::#{message_regexp}")
    matcher_type.match message
  end

  def self.validate_message(message)
    IrcMessageTypes.constants.map do |message_regexp|
      IrcMessage.message_matches(message_regexp, message)
    end.compact.first
  end

  def initialize(options = {})
    @validator = IrcMessageTypes::GENERIC_IRC_MESSAGE_MATCHER
    options = IrcMessage.parse(options) if options.is_a?(String)
    super(options)
  end

  def method_symbol
    "on_#{type.downcase.to_s}_messages"
  end

  def to_s
    new_message = build_message    
    validator =~ new_message ? new_message : nil
  end

  protected

  def build_message
    new_message = ""
    new_message << ":#{user} " if user
    new_message << "#{type.to_s} "
    new_message << "#{recipient} " if recipient
    new_message << "#{message}" if message
    new_message 
  end
end

class PassMessage < IrcMessage
  def initialize(options = {})
    raise ArgumentError.new('Required arguments not supplied: (password)') unless options[:password]
    super(options.merge(:type => :pass))
    @validator = IrcMessageTypes::PASS_MATCHER
  end

  protected

  def build_message
    "PASS #{password}"
  end
end

class NickMessage < IrcMessage
  def initialize(options = {})
    raise ArgumentError.new('Required arguments not supplied: (nickname)') unless options[:nickname]
    super(options.merge(:type => :nick))
    @validator = IrcMessageTypes::NICK_MATCHER
  end

  protected

  def build_message
    message = ""
    message << ":#{user} " if user
    message << "NICK #{nickname}"
  end
end

class UserMessage < IrcMessage
  def initialize(options = {})
    raise ArgumentError.new('Required arguments not supplied: (nickname,mode,realname)') unless options[:nickname] && options [:mode] && options[:realname]
    super(options.merge(:type => :user))
  end

  protected

  def build_message
    "USER #{nickname} #{mode} * :#{realname}"
  end
end

class JoinMessage < IrcMessage
  def initialize(options = {})
    raise ArgumentError.new('Required arguments not supplied: (channel)') unless options[:channel]
    super(options.merge(:type => :join))
  end

  protected

  def build_message
    "JOIN #{channel} #{key}".strip
  end
end

class PongMessage < IrcMessage
  def initialize(options = {})
    super(options.merge(:type => :pong))
    @validator = IrcMessageTypes::PONG_MATCHER
  end

  def build_message
    "PONG #{server}".strip
  end
end

class PrivMessage < IrcMessage
  def initialize(options = {})
    raise ArgumentError.new('Required arguments not supplied: (recipient,message)') unless options[:recipient] && options[:message]
    super(options.merge(:type => :privmsg))
    validator = IrcMessageTypes::PRIVMSG_MATCHER
  end

  protected

  def build_message
    "PRIVMSG #{recipient} :#{message}"
  end
end

module IrcMessageTypes
  PASS_MATCHER = /(?<type>PASS) (?<password>\S+)/
  NICK_MATCHER = /(:(?<user>\S+) )?(?<type>NICK) (?<nickname>\S+)/
  USER_MATCHER = /(:(?<user>\S+) )?(?<type>USER) (?<username>\S+) (?<hostname>\S+) (?<servername>\S+) :(?<realname>.+)/
  SERVER_MATCHER = /(:(?<user>\S+) )?(?<type>SERVER) (?<servername>\S+) (?<hopcount>\S+) :(?<info>.+)/
  OPER_MATCHER = /(?<type>OPER) (?<user>\S+) (?<password>\S+)/
  QUIT_MATCHER = /(:(?<user>\S+) )?(?<type>QUIT) :(?<message>.+)/
  SQUIT_MATCHER = /(:(?<user>\S*) )?(?<type>SQUIT) (?<server>\S+) :(?<comment>.+)/
  JOIN_MATCHER = /(:(?<user>\S+) )?(?<type>JOIN) (?<channel>\S+(,\S+)?)( (?<key>\S+))?/
  PART_MATCHER = /(:(?<user>\S+) )?(?<type>PART) (?<channel>\S+(,\S+)?)( :(?<message>.+))?/
  CHANNEL_MODE_MATCHER = /(:(?<user>\S+) )?(?<type>MODE) (?<channel>[#|&]{1}\S+) (?<operator>[+|-]{1})(?<mode>\w{1})( (?<limit>\d+))?( (?<user>\w+))?( (?<banmask>\S+))?/
  USER_MODE_MATCHER = /(:(?<user>\S+) )?(?<type>MODE)( (?<recipient>\S+))? :(?<operator>[+|-]{1})(?<mode>\w{1})/
  TOPIC_MATCHER = /(:(?<user>\S+) )?(?<type>TOPIC) (?<channel>\S+)( :(?<topic>.*+))?/
  NAMES_MATCHER = /(?<type>NAMES)( (?<channel>\S+))?/
  LIST_MATCHER = /(?<type>LIST)( (?<channel>\S+))?/
  INVITE_MATCHER = /(:(?<user>\S+) )?(?<type>INVITE) (?<recipient>\S+) (?<channel>\S+)/
  KICK_MATCHER = /(:(?<user>\S+) )?(?<type>KICK) (?<channel>\S+) (?<recipient>\S+)( :(?<message>.*))?/
  PRIVMSG_MATCHER = /(:(?<user>\S+) )?(?<type>PRIVMSG) (?<recipient>\S+) :(?<message>.+)/
  NOTICE_MATCHER = /(:(?<user>\S+) )?(?<type>NOTICE) (?<recipient>\S+) :(?<message>.+)/
  MOTD_MATCHER = /(?<type>MOTD)/
  VERSION_MATCHER = /(:(?<user>\S+) )?(?<type>VERSION) (?<target>\S+)/
  STATS_MATCHER = /(:(?<user>\S+) )?(?<type>STATS) (?<query>\S{1})( (?<target>\S+))?/
  LINKS_MATCHER = /(?<type>LINKS)( (?<remoteserver>\S+))? (?<servermask>\S+)/
  TIME_MATCHER = /(:(?<user>\S+) )?(?<type>TIME) (?<target>\S+)/
  CONNECT_MATCHER = /(:(?<user>\S+) )?(?<type>CONNECT) (?<target>\S+)( (?<port>\d+))?( (?<remoteserver>\S+))?/
  TRACE_MATCHER = /(:(?<user>\S+) )?(?<type>TRACE) (?<target>\S+)/
  ADMIN_MATCHER = /(?<type>ADMIN) (?<target>\S+)/
  INFO_MATCHER = /(:(?<user>\S+) )?(?<type>INFO) (?<target>\S+)/
  SQUERY_MATCHER = /(?<type>SQUERY)( (?<service>\S+))?( :(?<message>.*))?/
  WHOWAS_MATCHER = /(?<type>WHOWAS) (?<nickname>\S+)( (?<count>\d+))?( (?<target>\S+))?/
  WHOIS_MATCHER = /(?<type>WHOIS) (?<target>\S+)( (?<mask>\S+))?/
  WHO_MATCHER = /(?<type>WHO)( (?<mask>\S+))?( (?<o>[o]{1}))?/
  KILL_MATCHER = /(?<type>KILL) (?<nickname>\S+) (?<comment>.*)/
  PING_MATCHER = /(?<type>PING) (?<server>.*)/
  PONG_MATCHER = /(?<type>PONG)( (?<daemon>.*))?/
  ERROR_MATCHER = /(?<type>ERROR) :(?<message>.*)/
  AWAY_MATCHER = /(:(?<user>\S+) )?(?<type>AWAY)( :(?<message>.*))?/
  REHASH_MATCHER = /(?<type>REHASH)/
  RESTART_MATCHER = /(?<type>RESTART)/
  SUMMON_MATCHER = /(?<type>SUMMON) (?<recipient>\S+)( (?<target>\S+))?/
  USERS_MATCHER = /(:(?<user>\S+) )?(?<type>USERS) (?<target>\S+)/
  WALLOPS_MATCHER = /(:(?<user>\S+) )?(?<type>WALLOPS)( :(?<message>.*))?/
  USERHOST_MATCHER = /(?<type>USERHOST) (?<nickname>.*)/
  ISON_MATCHER = /(?<type>ISON) (?<nickname>.*)/

  GENERIC_IRC_MESSAGE_MATCHER = /(:(?<user>\S+) )?(?<type>\S+)( (?<recipient>\S+))?( (?<message>.*))?/
end
