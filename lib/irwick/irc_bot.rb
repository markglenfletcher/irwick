class IrcBot
  attr_reader :server
  attr_accessor :plugins

  def initialize(server, options = {})
    @terminate,@reload_bot = false,false
    @server = server
    @options = options
    @plugins = load_plugins(options[:plugins] || [])
  end

  def start
    begin
      server.connect
      while message = read_from_server
        plugin_responses = notify_plugins message
        handle_responses plugin_responses
      end
      @reload_bot
    ensure
      shutdown
    end
  end

  def notify_plugins(message)
    plugins.flat_map do |plugin|
      notify_plugin plugin, message
    end
  end

  def handle_responses(responses)
    responses.each do |response|
      if response.is_a?(ControlMessage)
        execute_control_message response
      else 
        write_to_server response
      end
    end
  end

  def execute_control_message(control_message)
    begin
      send(control_message.method) if control_message_permitted?(control_message.method)
    rescue NoMethodError
      nil
    end
  end

  private

  def load_plugins(plugin_constants)
    plugin_constants.map do |plugin|
      load_plugin plugin
    end
  end

  def load_plugin(plugin_const)
    plugin_class = IrcPlugin.valid_plugin?(plugin_const)
    raise ArgumentError.new('All plugins must be a subclass of IrcPlugin') unless plugin_class
    plugin_class.new(@options)
  end

  def notify_plugin(plugin, message)
    callbacks = [
      plugin.method(:on_all_messages), 
      plugin.method(message.method_symbol.to_sym)
    ]
    callbacks.flat_map do |callback|
      begin
        callback.call(message)
      rescue Exception => e
        e
      end
    end.compact
  end

  def control_message_permitted?(method)
    [:disconnect, :reload].include?(method)
  end

  def read_from_server
    unless @terminate
      IrcTools::Message.new server.read
    else
      false
    end
  end

  def write_to_server(response)
    server.write response.to_s
  end

  def shutdown
    write_to_server(IrcTools::QuitMessage.new)
    server.disconnect
  end

  def reload
    @terminate = true
    @reload_bot = true
  end

  def disconnect
    @terminate = true
    @reload_bot = false
  end
end