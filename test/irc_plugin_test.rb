require_relative 'test_helper'

class IrcPluginTest < Minitest::Test
  def setup
    @plugin = IrcPlugin.new
    @message = mock()
  end

  def test_default_methods_are_present
    refute_nil @plugin.method(:on_all_messages)
    assert_nil @plugin.send(:on_all_messages)
    refute_nil @plugin.method(:on_unknown_messages)
    assert_nil @plugin.send(:on_unknown_messages)
  end

  def test_can_handle_all_messages_sent_to_it
    ['pass', 'join', 'privmsg'].each do |message_type|
      method = :"on_#{message_type}_received"
      assert_equal true, @plugin.respond_to?(method)
      assert_nil @plugin.send(method, @message)
      refute_nil @plugin.method(method)
    end

    assert_raises NoMethodError do
      @plugin.missing_method
    end
  end

  def test_overrides_work_as_expected
    assert_equal nil, @plugin.on_all_messages
    def @plugin.on_all_messages; true; end
    assert_equal true, @plugin.on_all_messages
  end

  def test_plugin_can_define_own_methods
    def @plugin.my_method; true; end
    assert_equal true, @plugin.my_method
  end

  def test_valid_plugin
    assert_equal Plugin, IrcPlugin.valid_plugin?('Plugin')
    assert_equal false, IrcPlugin.valid_plugin?('InvalidPlugin')
    assert_equal false, IrcPlugin.valid_plugin?('NotExistantPluginClass')
  end
end

class Plugin < IrcPlugin; end
class InvalidPlugin; end

