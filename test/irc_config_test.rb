require_relative 'test_helper'

class IrcConfigTest < Minitest::Test
  def setup
    @options = {
      nick_name: 'swarmhorderrndm',
      user_name: 'swarmhorderrndm',
      real_name: 'Ruby Bot testing',
      host_name: "8",
      server_name: "*",
      pass: "*",
      owner: 'mfmfmfmfmfmf',
      command_key: '4325642',
      remote_servers: [
        {
          server_ref: 'freenode',
          host_name: 'holmes.freenode.net',
          port: 6667
        },
        {
          server_ref: 'another',
          host_name: 'server.another.net',
          port: 6668
        }
      ]
    }
    @config = IrcConfig.new(@options)
  end
  
  def test_acquires_basic_options
    assert_equal @options[:nick_name], @config.nick_name
    assert_equal @options[:user_name], @config.user_name
    assert_equal @options[:real_name], @config.real_name
    assert_equal @options[:host_name], @config.host_name
    assert_equal @options[:server_name], @config.server_name
    assert_equal @options[:pass], @config.pass
  end

  def test_acquires_remote_servers
    assert_equal 2, @config.remote_servers.count
    first_server = @config.remote_servers.first
    assert_equal 'freenode', first_server.server_ref
    assert_equal 'holmes.freenode.net', first_server.host_name
    assert_kind_of Integer, first_server.port
    assert_equal 6667, first_server.port
  end

  def test_to_hash
    assert_equal @options, @config.to_hash
  end

  def test_raises_argument_error_if_basic_options_are_missing
    [:nick_name, :user_name, :real_name, :host_name, :server_name, :pass].each do |basic_option|
      assert_raises ArgumentError do
        local_options = @options
        local_options.delete(basic_option)
        IrcConfig.new(local_options)
      end
    end
  end

  def test_raises_argument_error_if_at_least_one_server_is_not_present
    assert_raises ArgumentError do
      IrcConfig.new(@options.merge(remote_servers: []))
    end
  end

  def test_raises_argument_error_if_server_config_array_is_not_present
    assert_raises ArgumentError do
      local_options = @options
      local_options.delete(:remote_servers)
      IrcConfig.new(local_options)
    end
  end

  def test_merge_server_overrides_config
    server_config = [
        {
          server_ref: 'freenode',
          host_name: 'holmes.freenode.net',
          port: 6667,
          nick_name: 'Geoff'
        }
    ]
    local_options = @options
    local_options[:remote_servers] = server_config
    local_config = IrcConfig.new(local_options)
    remote_server = local_config.remote_servers.first

    merge_config = local_config.to_hash.merge(remote_server.to_h)

    assert_equal 'Geoff', merge_config[:nick_name]
  end
end