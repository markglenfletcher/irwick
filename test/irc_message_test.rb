require_relative 'test_helper'

class IrcMessageTest < Minitest::Test
  # def test_message_factory_should_correctly_classify_messages
  #   {
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
  #     :SERVICE => ['SERVICE dict * *.fr 0 0 :French Dictionary']
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

    message = ':WiZ!jto@tolsun.oulu.fi NICK Kilroy'
    assert_irc_message_contains IrcMessage.parse(message), :user => 'WiZ!jto@tolsun.oulu.fi', :nickname => 'Kilroy'

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

    message = ':syrk!kalt@millennium.stealth.net QUIT :Gone to have lunch'
    assert_irc_message_contains IrcMessage.parse(message), :user => 'syrk!kalt@millennium.stealth.net', :message => 'Gone to have lunch'

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

    message = ':WiZ!jto@tolsun.oulu.fi JOIN #Twilight_zone'
    assert_irc_message_contains IrcMessage.parse(message), :user => 'WiZ!jto@tolsun.oulu.fi', :channel => '#Twilight_zone'

    # PART

    message = 'PART #twilight_zone'
    assert_irc_message_contains IrcMessage.parse(message), :channel => '#twilight_zone'

    message = 'PART #oz-ops,&group5'
    assert_irc_message_contains IrcMessage.parse(message), :channel => '#oz-ops,&group5'

    message = ':WiZ!jto@tolsun.oulu.fi PART #playzone :I lost'
    assert_irc_message_contains IrcMessage.parse(message), :user => 'WiZ!jto@tolsun.oulu.fi', :channel => '#playzone', :message => 'I lost'

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
    
    message = ':WiZ!jto@tolsun.oulu.fi MODE #eu-opers -l'
    assert_irc_message_contains IrcMessage.parse(message), :user => 'WiZ!jto@tolsun.oulu.fi', :channel => '#eu-opers', :operator => '-', :mode => 'l'

    # MODE User

    message = ':WiZ MODE -w'
    assert_irc_message_contains IrcMessage.parse(message), :user => 'WiZ', :operator => '-', :mode => 'w'

    message = ':Angel MODE Angel +i'
    assert_irc_message_contains IrcMessage.parse(message), :user => 'Angel', :recipient => 'Angel', :operator => '+', :mode => 'i'

    message = 'MODE WiZ -o'
    assert_irc_message_contains IrcMessage.parse(message), :recipient => 'WiZ', :operator => '-', :mode => 'o'

    # TOPIC

    message = ':WiZ!jto@tolsun.oulu.fi TOPIC #test :New topic'
    assert_irc_message_contains IrcMessage.parse(message), :user => 'WiZ!jto@tolsun.oulu.fi', :channel => '#test', :topic => 'New topic'
    
    message = 'TOPIC #test :another topic'
    assert_irc_message_contains IrcMessage.parse(message), :user => nil, :channel => '#test', :topic => 'another topic'

    message = 'TOPIC #test :'
    assert_irc_message_contains IrcMessage.parse(message), :channel => '#test', :topic => ''

    message = 'TOPIC #test'
    assert_irc_message_contains IrcMessage.parse(message), :channel => '#test'    

    # NAMES

    message = 'NAMES #twilight_zone,#42'
    assert_irc_message_contains IrcMessage.parse(message), :channel => '#twilight_zone,#42'

    message = 'NAMES'
    assert_irc_message_contains IrcMessage.parse(message), :type => :names, :channel => nil

    # LIST

    message = 'LIST'
    assert_irc_message_contains IrcMessage.parse(message), :type => :list, :channel => nil
    
    message = 'LIST #twilight_zone,#42'
    assert_irc_message_contains IrcMessage.parse(message), :channel => '#twilight_zone,#42'

    # INVITE
    message = ':Angel INVITE Wiz #Dust'
    assert_irc_message_contains IrcMessage.parse(message), :user => 'Angel', :recipient => 'Wiz', :channel => '#Dust'

    message = 'INVITE Wiz #Twilight_Zone'
    assert_irc_message_contains IrcMessage.parse(message), :recipient => 'Wiz', :channel => '#Twilight_Zone'

    message = ':Angel!wings@irc.org INVITE Wiz #Dust'
    assert_irc_message_contains IrcMessage.parse(message), :user => 'Angel!wings@irc.org', :recipient => 'Wiz', :channel => '#Dust'

    # KICK

    message = 'KICK &Melbourne Matthew'
    assert_irc_message_contains IrcMessage.parse(message), :channel => '&Melbourne', :recipient => 'Matthew' 

    message = 'KICK #Finnish John :Speaking English'
    assert_irc_message_contains IrcMessage.parse(message), :channel => '#Finnish', :recipient => 'John', :message => 'Speaking English'

    message = ':WiZ KICK #Finnish John'
    assert_irc_message_contains IrcMessage.parse(message), :user => 'WiZ', :channel => '#Finnish', :recipient => 'John'
    
    message = ':WiZ!jto@tolsun.oulu.fi KICK #Finnish John'
    assert_irc_message_contains IrcMessage.parse(message), :user => 'WiZ!jto@tolsun.oulu.fi', :channel => '#Finnish', :recipient => 'John'

    # PRIVMSG
    message = ":Angel PRIVMSG Wiz :Hello are you receiving this message ?"
    assert_irc_message_contains IrcMessage.parse(message), :user => 'Angel', :recipient => 'Wiz', :message => 'Hello are you receiving this message ?'

    message = "PRIVMSG Angel :yes I'm receiving it !"
    assert_irc_message_contains IrcMessage.parse(message), :user => nil, :recipient => 'Angel', :message => "yes I'm receiving it !"
    
    message = "PRIVMSG jto@tolsun.oulu.fi :Hello !"
    assert_irc_message_contains IrcMessage.parse(message), :user => nil, :recipient => 'jto@tolsun.oulu.fi', :message => 'Hello !'
    
    message = "PRIVMSG $*.fi :Server tolsun.oulu.fi rebooting."
    assert_irc_message_contains IrcMessage.parse(message), :user => nil, :recipient => '$*.fi', :message => 'Server tolsun.oulu.fi rebooting.'

    message = "PRIVMSG #*.edu :NSFNet is undergoing work, expect interruptions"
    assert_irc_message_contains IrcMessage.parse(message), :user => nil, :recipient => '#*.edu', :message => 'NSFNet is undergoing work, expect interruptions'

    message = 'PRIVMSG kalt%millennium.stealth.net@irc.stealth.net :Are you a frog?'
    assert_irc_message_contains IrcMessage.parse(message), :recipient => 'kalt%millennium.stealth.net@irc.stealth.net', :message => 'Are you a frog?'

    message = 'PRIVMSG kalt%millennium.stealth.net :Do you like cheese?'
    assert_irc_message_contains IrcMessage.parse(message), :recipient => 'kalt%millennium.stealth.net', :message => 'Do you like cheese?'

    message = 'PRIVMSG Wiz!jto@tolsun.oulu.fi :Hello !'
    assert_irc_message_contains IrcMessage.parse(message), :recipient => 'Wiz!jto@tolsun.oulu.fi', :message => 'Hello !'

    # NOTICE
    message = ":Angel NOTICE Wiz :Hello are you receiving this message ?"
    assert_irc_message_contains IrcMessage.parse(message), :user => 'Angel', :recipient => 'Wiz', :message => 'Hello are you receiving this message ?'

    message = "NOTICE Angel :yes I'm receiving it !"
    assert_irc_message_contains IrcMessage.parse(message), :user => nil, :recipient => 'Angel', :message => "yes I'm receiving it !"
    
    message = "NOTICE jto@tolsun.oulu.fi :Hello !"
    assert_irc_message_contains IrcMessage.parse(message), :user => nil, :recipient => 'jto@tolsun.oulu.fi', :message => 'Hello !'

    message = "NOTICE $*.fi :Server tolsun.oulu.fi rebooting."
    assert_irc_message_contains IrcMessage.parse(message), :user => nil, :recipient => '$*.fi', :message => 'Server tolsun.oulu.fi rebooting.'

    message = "NOTICE #*.edu :NSFNet is undergoing work, expect interruptions"
    assert_irc_message_contains IrcMessage.parse(message), :user => nil, :recipient => '#*.edu', :message => 'NSFNet is undergoing work, expect interruptions'

    message = 'NOTICE kalt%millennium.stealth.net@irc.stealth.net :Are you a frog?'
    assert_irc_message_contains IrcMessage.parse(message), :recipient => 'kalt%millennium.stealth.net@irc.stealth.net', :message => 'Are you a frog?'

    message = 'NOTICE kalt%millennium.stealth.net :Do you like cheese?'
    assert_irc_message_contains IrcMessage.parse(message), :recipient => 'kalt%millennium.stealth.net', :message => 'Do you like cheese?'

    message = 'NOTICE Wiz!jto@tolsun.oulu.fi :Hello !'
    assert_irc_message_contains IrcMessage.parse(message), :recipient => 'Wiz!jto@tolsun.oulu.fi', :message => 'Hello !'

    # MOTD

    message = 'MOTD'
    assert_irc_message_contains IrcMessage.parse(message), :type => :motd

    # STATS
    message = 'STATS m'
    assert_irc_message_contains IrcMessage.parse(message), :type => :stats, :query => 'm'

    message = ':Wiz STATS c eff.org'
    assert_irc_message_contains IrcMessage.parse(message), :user => 'Wiz', :query => 'c', :target => 'eff.org'

    # VERSION

    message = ':Wiz VERSION *.se'
    assert_irc_message_contains IrcMessage.parse(message), :user => 'Wiz', :target => '*.se'

    message = 'VERSION tolsun.oulu.fi'
    assert_irc_message_contains IrcMessage.parse(message), :target => 'tolsun.oulu.fi'

    # LINKS

    message = 'LINKS *.au'
    assert_irc_message_contains IrcMessage.parse(message), :servermask => '*.au'

    message = 'LINKS *.bu.edu *.edu'
    assert_irc_message_contains IrcMessage.parse(message), :remoteserver => '*.bu.edu', :servermask => '*.edu'

    # TIME

    message = 'TIME tolsun.oulu.fi'
    assert_irc_message_contains IrcMessage.parse(message), :target => 'tolsun.oulu.fi'
    
    message = ':Angel TIME *.au'
    assert_irc_message_contains IrcMessage.parse(message), :user => 'Angel', :target => '*.au'

    # CONNECT
    message = 'CONNECT tolsun.oulu.fi'
    assert_irc_message_contains IrcMessage.parse(message), :target => 'tolsun.oulu.fi'

    message = ':WiZ CONNECT eff.org 6667 csd.bu.edu'
    assert_irc_message_contains IrcMessage.parse(message), :user => 'WiZ', :target => 'eff.org', :port => '6667', :remoteserver => 'csd.bu.edu'

    # TRACE
    message = 'TRACE *.oulu.fi'
    assert_irc_message_contains IrcMessage.parse(message), :target => '*.oulu.fi'
    
    message = ':WiZ TRACE AngelDust'
    assert_irc_message_contains IrcMessage.parse(message), :user => 'WiZ', :target => 'AngelDust'

    # ADMIN

    message = 'ADMIN tolsun.oulu.fi'
    assert_irc_message_contains IrcMessage.parse(message), :target => 'tolsun.oulu.fi'

    message = ':WiZ ADMIN *.edu'
    assert_irc_message_contains IrcMessage.parse(message), :target => '*.edu'

    message = 'ADMIN syrk'
    assert_irc_message_contains IrcMessage.parse(message), :target => 'syrk'

    # INFO

    message = 'INFO csd.bu.edu'
    assert_irc_message_contains IrcMessage.parse(message), :target => 'csd.bu.edu'

    message = ':Avalon INFO *.fi'
    assert_irc_message_contains IrcMessage.parse(message), :user => 'Avalon', :target => '*.fi'

    message = 'INFO Angel'
    assert_irc_message_contains IrcMessage.parse(message), :target => 'Angel'

    # SERVLIST
    # TODO

    # SQUERY

    message = 'SQUERY irchelp :HELP privmsg'
    assert_irc_message_contains IrcMessage.parse(message), :service => 'irchelp', :message => 'HELP privmsg'

    message = 'SQUERY dict@irc.fr :fr2en blaireau'
    assert_irc_message_contains IrcMessage.parse(message), :service => 'dict@irc.fr', :message => 'fr2en blaireau'

    # WHO

    message = 'WHO *.fi'
    assert_irc_message_contains IrcMessage.parse(message), :mask => '*.fi', :o => nil 

    message = 'WHO jto* o'
    assert_irc_message_contains IrcMessage.parse(message), :mask => 'jto*', :o => 'o'

    # WHOIS

    message = 'WHOIS wiz'
    assert_irc_message_contains IrcMessage.parse(message), :target => 'wiz'

    message = 'WHOIS eff.org trillian'
    assert_irc_message_contains IrcMessage.parse(message), :target => 'eff.org', :mask => 'trillian'

    # WHOWAS

    message = 'WHOWAS Wiz'
    assert_irc_message_contains IrcMessage.parse(message), :nickname => 'Wiz'

    message = 'WHOWAS Mermaid 9'
    assert_irc_message_contains IrcMessage.parse(message), :nickname => 'Mermaid', :count => '9'
    
    message = 'WHOWAS Trillian 1 *.edu'
    assert_irc_message_contains IrcMessage.parse(message), :nickname => 'Trillian', :count => '1', :target => '*.edu'

    # PING
    message = 'PING tolsun.oulu.fi'
    assert_irc_message_contains IrcMessage.parse(message), :server => 'tolsun.oulu.fi'

    message = 'PING WiZ'
    assert_irc_message_contains IrcMessage.parse(message), :server => 'WiZ'
  end

  def test_validates_message_recognises_valid_message
    assert_equal false, IrcMessage.validate_message('PASS pass').nil?
  end

  def test_validates_message_recognises_invalid_message
    assert_equal true, IrcMessage.validate_message('PASS').nil?
  end

  def test_new_accepts_hash
    refute_nil IrcMessage.new({:user=>"prev", :type=>:nick, :nickname=>"nick", :raw_message=>":prev NICK nick"})
  end

  def test_to_s_is_correct
    # PASS
    assert_equal 'PASS pass', IrcMessage.new(:type => :pass, :pass => 'pass').to_s

    # NICK
    assert_equal ':prev NICK nick', IrcMessage.new(:type => :nick, :user => 'prev', :nick => 'nick').to_s
    assert_equal 'NICK nick', IrcMessage.new(:type => :nick, :nick => 'nick').to_s
    assert_equal ':WiZ!jto@tolsun.oulu.fi NICK Kilroy', IrcMessage.new(:type => :nick, :user => 'WiZ!jto@tolsun.oulu.fi', :nick => 'Kilroy').to_s

  end

  def test_to_s_returns_nil_if_message_invalid
    assert_equal nil, IrcMessage.new(:type => :nick).to_s
  end

  def test_to_s_returns_nil_if_expected_field_is_missing
    assert_equal nil, IrcMessage.new(:nick => 'nick').to_s
  end

  private

  def assert_irc_message_contains(irc_message, contents = {})
    contents.each { |k,v| assert_equal v, irc_message[k] }
  end
end