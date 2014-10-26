require 'ostruct'

class IrcMessage < OpenStruct
  def self.parse(raw_message)
    IrcMessageTypes.constants.each do |message_regexp|
      if matches = message_matches(message_regexp, raw_message)
        attributes = Hash[matches.names.map { |name| [name.to_sym, matches[name.to_sym]] }]
        return attributes.merge(:type => matches[:type].downcase.to_sym, :raw_message => raw_message)
      end
    end
    return {:type => :unknown, :raw_message => raw_message}
  end

  def self.message_matches(message_regexp, message)
    matcher_type = Object.const_get("IrcMessageTypes::#{message_regexp}")
    matcher_type.match message
  end

  def initialize(options = {})
    options = IrcMessage.parse(options) if options.is_a?(String)
    super(options)
  end

  def method_symbol
    "on_#{type.downcase.to_s}_messages"
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
  USER_MODE_MATCHER = /(:(?<user>\S+) )?(?<type>MODE)( (?<to_user>\S+))? (?<operator>[+|-]{1})(?<mode>\w{1})/
  TOPIC_MATCHER = /(:(?<user>\S+) )?(?<type>TOPIC) (?<channel>\S+)( :(?<topic>.*+))?/

  PRIVMSG_MATCHER = /(:(?<user>\S+) )?(?<type>PRIVMSG) (?<to_user>\S+) :(?<message>.+)/
  NOTICE_MATCHER = /(:(?<user>\S+) )?(?<type>NOTICE) (?<to_user>\S+) :(?<message>.+)/

  PING_MATCHER = /(?<type>PING) (?<server>.*)/
end
