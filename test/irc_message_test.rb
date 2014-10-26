require_relative 'test_helper'

class IrcMessageTest < Minitest::Test
  # def test_message_factory_should_correctly_classify_messages
  #   {
  #     :TOPIC => [':Wiz TOPIC #test :New topic','TOPIC #test :another topic','TOPIC #test'],
  #     :NAMES => ['NAMES #twilight_zone,#42','NAMES'],
  #     :LIST => ['LIST','LIST #twilight_zone,#42'],
  #     :INVITE => [':Angel INVITE Wiz #Dust','INVITE Wiz #Twilight_Zone'],
  #     :KICK =>  ['KICK &Melbourne Matthew','KICK #Finnish John :Speaking English',':WiZ KICK #Finnish John'],
  #     :VERSION => [':Wiz VERSION *.se','VERSION tolsun.oulu.fi'],
  #     :STATS => ['STATS m',':Wiz STATS c eff.org'],
  #     :LINKS => ['LINKS *.au','LINKS *.bu.edu *.edu'],
  #     :TIME => ['TIME tolsun.oulu.fi',':Angel TIME *.au'],
  #     :CONNECT => ['CONNECT tolsun.oulu.fi',':WiZ CONNECT eff.org 6667 csd.bu.edu'],
  #     :TRACE => ['TRACE *.oulu.fi',':WiZ TRACE AngelDust'],
  #     :ADMIN => ['ADMIN tolsun.oulu.fi',':WiZ ADMIN *.edu'],
  #     :INFO => ['INFO csd.bu.edu',':Avalon INFO *.fi','INFO Angel'],
  #     :WHO => ['WHO *.fi','WHO jto* o'],
  #     :WHOIS => ['WHOIS wiz','WHOIS eff.org trillian'],
  #     :WHOWAS => ['WHOWAS Wiz','WHOWAS Mermaid 9','WHOWAS Trillian 1 *.edu'],
  #     :KILL => ['KILL David (csd.bu.edu <- tolsun.oulu.fi)'],
  #     :PING => ['PING tolsun.oulu.fi','PING WiZ'],
  #     :PONG => ['PONG csd.bu.edu tolsun.oulu.fi'],
  #     :ERROR => ['ERROR :Server *.fi already exists'],
  #     :AWAY => ['AWAY :Gone to lunch.  Back in 5', ':WiZ AWAY'],
  #     :REHASH => ['REHASH'],
  #     :RESTART => ['RESTART'],
  #     :SUMMON => ['SUMMON jto', 'SUMMON jto tolsun.oulu.fi'],
  #     :USERS => ['USERS eff.org',':John USERS tolsun.oulu.fi'],
  #     :WALLOPS => [":csd.bu.edu WALLOPS :Connect '*.uiuc.edu 6667' from Joshua"],
  #     :USERHOST => ['USERHOST Wiz Michael Marty p'],
  #     :ISON => ['ISON phone trillian WiZ jarlek Avalon Angel Monstah']
  #   }.each do |k,v|
  #     v.each { |m| assert_equal k, IrcMessage.classify(m) }
  #   end
  # end

  def test_method_symbol_is_correct
    assert_equal 'on_privmsg_messages', IrcMessage.new(":Angel PRIVMSG Wiz :Hello are you receiving this message ?").method_symbol
  end

  def test_new_doesnt_blow_up_with_unknown_message
    refute_nil IrcMessage.new(":holmes.freenode.net 002 swarmhorderrndm :Your host is holmes.freenode.net[83.170.73.249/6667], running version ircd-seven-1.1.3")
  end

  def test_parsed_message_behaves_correctly
    # PASS
    message = 'PASS password'
    assert_irc_message_contains IrcMessage.parse(message), :password => 'password', :type => :pass, :raw_message => message

    # NICK
    message = ':prev NICK nick'
    assert_irc_message_contains IrcMessage.parse(message), :user => 'prev', :nickname => 'nick'

    message = 'NICK nick'
    assert_irc_message_contains IrcMessage.parse(message), :nickname => 'nick'

    # USER

    message = 'USER guest tolmoon tolsun :Ronnie Reagan'
    assert_irc_message_contains IrcMessage.parse(message), :username => 'guest', :hostname => 'tolmoon', :servername => 'tolsun', :realname => 'Ronnie Reagan'
    
    message = ':testnick USER guest tolmoon tolsun :Ronnie Reagan'
    assert_irc_message_contains IrcMessage.parse(message), :user => 'testnick', :username => 'guest', :hostname => 'tolmoon', :servername => 'tolsun', :realname => 'Ronnie Reagan'

    # SERVER
    message = 'SERVER test.oulu.fi 1 :[tolsun.oulu.fi] Experimental server'
    assert_irc_message_contains IrcMessage.parse(message), :servername => 'test.oulu.fi', :hopcount =>  '1', :info => '[tolsun.oulu.fi] Experimental server'
    
    message = ':tolsun.oulu.fi SERVER csd.bu.edu 5 :BU Central Server'
    assert_irc_message_contains IrcMessage.parse(message), :user => 'tolsun.oulu.fi', :servername => 'csd.bu.edu', :hopcount => '5', :info => 'BU Central Server'

    # OPER
    message = 'OPER foo bar'
    assert_irc_message_contains IrcMessage.parse(message), :user => 'foo', :password => 'bar'

    # QUIT
    message = 'QUIT :Gone to have lunch'
    assert_irc_message_contains IrcMessage.parse(message), :message => 'Gone to have lunch'

    # SQUIT 
    message = 'SQUIT tolsun.oulu.fi :Bad Link ?'
    assert_irc_message_contains IrcMessage.parse(message), :server => 'tolsun.oulu.fi',:comment => 'Bad Link ?'
        
    message = ':Trillian SQUIT cm22.eng.umd.edu :Server out of control'
    assert_irc_message_contains IrcMessage.parse(message), :user => 'Trillian', :server => 'cm22.eng.umd.edu', :comment => 'Server out of control' 

    # JOIN

    message = 'JOIN #foobar'
    assert_irc_message_contains IrcMessage.parse(message), :channel => '#foobar'

    message ='JOIN &foo fubar'
    assert_irc_message_contains IrcMessage.parse(message), :channel => '&foo', :key => 'fubar'

    message = 'JOIN #foo,&bar fubar'
    assert_irc_message_contains IrcMessage.parse(message), :channel => '#foo,&bar', :key => 'fubar'
    
    message = 'JOIN #foo,#bar fubar,foobar'
    assert_irc_message_contains IrcMessage.parse(message), :channel => '#foo,#bar', :key => 'fubar,foobar'
    
    message = 'JOIN #foo,#bar'
    assert_irc_message_contains IrcMessage.parse(message), :channel => '#foo,#bar'

    message = ':WiZ JOIN #Twilight_zone'
    assert_irc_message_contains IrcMessage.parse(message), :user => 'WiZ', :channel => '#Twilight_zone'

    # PART

    message = 'PART #twilight_zone'
    assert_irc_message_contains IrcMessage.parse(message), :channel => '#twilight_zone'

    message = 'PART #oz-ops,&group5'
    assert_irc_message_contains IrcMessage.parse(message), :channel => '#oz-ops,&group5'

    # MODE Channel

    message = 'MODE #Finnish +v Wiz'
    assert_irc_message_contains IrcMessage.parse(message), :channel => '#Finnish', :operator => '+', :mode => 'v', :user => 'Wiz'

    message = 'MODE #Fins -s'
    assert_irc_message_contains IrcMessage.parse(message), :channel => '#Fins', :operator => '-', :mode => 's'

    message = 'MODE #42 +k oulu'
    assert_irc_message_contains IrcMessage.parse(message), :channel => '#42', :operator => '+', :mode => 'k', :user => 'oulu'
    
    message = 'MODE #eu-opers +l 10'
    assert_irc_message_contains IrcMessage.parse(message), :channel => '#eu-opers', :operator => '+', :mode => 'l', :limit => '10'

    message = 'MODE &oulu +b'
    assert_irc_message_contains IrcMessage.parse(message), :channel => '&oulu', :operator => '+', :mode => 'b'

    message = 'MODE &oulu +b *!*@*'
    assert_irc_message_contains IrcMessage.parse(message), :channel => '&oulu', :operator => '+', :mode => 'b', :banmask => '*!*@*'

    message = 'MODE &oulu +b *!*@*.edu'
    assert_irc_message_contains IrcMessage.parse(message), :channel => '&oulu', :operator => '+', :mode => 'b', :banmask => '*!*@*.edu'
    
    # MODE User

    message = ':WiZ MODE -w'
    assert_irc_message_contains IrcMessage.parse(message), :user => 'WiZ', :operator => '-', :mode => 'w'

    message = ':Angel MODE Angel +i'
    assert_irc_message_contains IrcMessage.parse(message), :user => 'Angel', :to_user => 'Angel', :operator => '+', :mode => 'i'

    message = 'MODE WiZ -o'
    assert_irc_message_contains IrcMessage.parse(message), :to_user => 'WiZ', :operator => '-', :mode => 'o'

    # PRIVMSG
    message = ":Angel PRIVMSG Wiz :Hello are you receiving this message ?"
    assert_irc_message_contains IrcMessage.parse(message), :user => 'Angel', :to_user => 'Wiz', :message => 'Hello are you receiving this message ?'

    message = "PRIVMSG Angel :yes I'm receiving it !"
    assert_irc_message_contains IrcMessage.parse(message), :user => nil, :to_user => 'Angel', :message => "yes I'm receiving it !"
    
    message = "PRIVMSG jto@tolsun.oulu.fi :Hello !"
    assert_irc_message_contains IrcMessage.parse(message), :user => nil, :to_user => 'jto@tolsun.oulu.fi', :message => 'Hello !'
    
    message = "PRIVMSG $*.fi :Server tolsun.oulu.fi rebooting."
    assert_irc_message_contains IrcMessage.parse(message), :user => nil, :to_user => '$*.fi', :message => 'Server tolsun.oulu.fi rebooting.'

    message = "PRIVMSG #*.edu :NSFNet is undergoing work, expect interruptions"
    assert_irc_message_contains IrcMessage.parse(message), :user => nil, :to_user => '#*.edu', :message => 'NSFNet is undergoing work, expect interruptions'

    # NOTICE
    message = ":Angel NOTICE Wiz :Hello are you receiving this message ?"
    assert_irc_message_contains IrcMessage.parse(message), :user => 'Angel', :to_user => 'Wiz', :message => 'Hello are you receiving this message ?'

    message = "NOTICE Angel :yes I'm receiving it !"
    assert_irc_message_contains IrcMessage.parse(message), :user => nil, :to_user => 'Angel', :message => "yes I'm receiving it !"
    
    message = "NOTICE jto@tolsun.oulu.fi :Hello !"
    assert_irc_message_contains IrcMessage.parse(message), :user => nil, :to_user => 'jto@tolsun.oulu.fi', :message => 'Hello !'

    message = "NOTICE $*.fi :Server tolsun.oulu.fi rebooting."
    assert_irc_message_contains IrcMessage.parse(message), :user => nil, :to_user => '$*.fi', :message => 'Server tolsun.oulu.fi rebooting.'

    message = "NOTICE #*.edu :NSFNet is undergoing work, expect interruptions"
    assert_irc_message_contains IrcMessage.parse(message), :user => nil, :to_user => '#*.edu', :message => 'NSFNet is undergoing work, expect interruptions'

    # PING
    message = 'PING tolsun.oulu.fi'
    assert_irc_message_contains IrcMessage.parse(message), :server => 'tolsun.oulu.fi'

    message = 'PING WiZ'
    assert_irc_message_contains IrcMessage.parse(message), :server => 'WiZ'
  end

  def test_new_accepts_hash
    refute_nil IrcMessage.new({:user=>"prev", :type=>:nick, :nickname=>"nick", :raw_message=>":prev NICK nick"})
  end

  private

  def assert_irc_message_contains(irc_message, contents = {})
    contents.each { |k,v| assert_equal v, irc_message[k] }
  end
end