require 'minitest/autorun'
require 'minitest/unit'
require 'mocha/mini_test'
Dir["#{File.dirname(__FILE__)}/../lib/*.rb"].each { |f| require f }
