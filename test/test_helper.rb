require 'minitest/autorun'
require 'minitest/unit'
require 'mocha/mini_test'
Dir["#{File.dirname(__FILE__)}/../lib/*/*.rb"].each { |f| require f }
Dir["#{File.dirname(__FILE__)}/../lib/irwick/plugins/*.rb"].each { |f| require f }
