require 'ostruct'

class IrcConfig
  attr_accessor :nick_name,
    :user_name,
    :real_name,
    :host_name,
    :server_name,
    :pass,
    :owner,
    :command_key,
    :remote_servers

  def initialize(options = {})
    validate options
    @nick_name = options[:nick_name]
    @user_name = options[:user_name]
    @real_name = options[:real_name]
    @host_name = options[:host_name]
    @server_name = options[:server_name]
    @pass = options[:pass]
    @owner = options[:owner]
    @command_key = options[:command_key]
    @remote_servers = extract_remote_servers options[:remote_servers]
  end

  def to_hash
    {
      nick_name: nick_name,
      user_name: user_name,
      real_name: real_name,
      host_name: host_name,
      server_name: server_name,
      pass: pass,
      owner: owner,
      command_key: command_key,
      remote_servers: remote_servers.map do |rs|
        {
          server_ref: rs.server_ref,
          host_name: rs.host_name,
          port: rs.port 
        }
      end
    }
  end

  private

  def extract_remote_servers(remote_server_array)
    remote_server_array.map do |rs|
      OpenStruct.new(rs)
    end
  end

  def validate(options)
    validate_basic options
    validate_server options[:remote_servers]
  end

  def validate_basic(options)
    basic_options = [:nick_name, :user_name, :real_name, :host_name, :server_name, :pass]
    basic_options.each do |basic_option|
      unless options.keys.include?(basic_option)
        raise ArgumentError.new('One or more of the basic configuration options is missing')
      end
    end
  end

  def validate_server(options)
    raise ArgumentError.new('At least one remote server must be present in the configuration') unless options && options.count > 0
  end
end