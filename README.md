## irwick

irwick aims to allow ruby developers the freedom to create complex features for irc bots via plugins without having to worry about server connections, channel management and message sending.

The irwick project aims to make creating, reading and sending messages simple. I hope to develop this over time.

## Installation
```shell
gem install irwick
```
## Configuration

Change the config to suit your needs.

Minimum config required:
```json
{
  "nick_name": "my_nick",
  "user_name": "my_name",
  "real_name": "My Real Name",
  "host_name": 8,
  "server_name": "*",
  "pass": "*",
  "owner": "ownernick",
  "command_key": "p455w0rdZ",
  "remote_servers": [
    {
      "server_ref": "freenode",
      "server_address": "holmes.freenode.net",
      "port": 6667,
      "plugins": [
        "ToolsPlugin",
        "ControlPlugin",
        "ConsoleLoggerPlugin"
      ],
      "channels": [
        "#irwick",
        "#irwick_testing"
      ]
    }
  ]
}
```

Add more servers and channels as required.

## Add your own plugin

Create a plugin in lib/irwick/plugins

```ruby
class MyPlugin < IrcPlugin
  def initialize(options = {})
    @options = options
  end
end
```

Write methods for each message type your plugin wants to respond to:

```ruby
class MyPlugin < IrcPlugin
  def initialize(options = {})
    @options = options
  end

  def on_privmsg_messages(message)
  end
end
```

Return an individual IrcMessage or an array:

```ruby
def on_join_messages(message)
  PrivMessage.new(:recipient => message.channel, :message => 'Welcome')
end

def on_privmsg_messages(message)
  [
    PrivMessage.new(:recipient => message.recipient, :message => 'Read this!'),
    PrivMessage.new(:recipient => message.recipient, :message => 'Read this too!')
  ]
end
```

Finally, ensure your plugin is registered with your bot in the config, for the correct server:

```json
{
  "nick_name": "my_nick",
  "user_name": "my_name",
  "real_name": "My Real Name",
  "host_name": 8,
  "server_name": "*",
  "pass": "*",
  "owner": "ownernick",
  "command_key": "p455w0rdZ",
  "remote_servers": [
    {
      "server_ref": "freenode",
      "server_address": "holmes.freenode.net",
      "port": 6667,
      "plugins": [
        "ToolsPlugin",
        "ControlPlugin",
        "ConsoleLoggerPlugin",
        "MyPlugin"
      ],
      "channels": [
        "#irwick",
        "#irwick_testing"
      ]
    }
  ]
}
```

## Usage
```shell
bundle exec bin/irwick
```
## Tests
```shell
bundle exec rake test
```
## License

irwick is relased under the [MIT License](http://www.opensource.org/licenses/MIT).