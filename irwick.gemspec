Gem::Specification.new do |s|
  s.name        = 'irwick'
  s.version     = '0.1.0'
  s.license    = 'MIT'
  s.summary     = "IRC bot with plugin architecture"
  s.description = "Simple bot, handles server connection and message sending. Writes to and reads from your plugins."
  s.authors     = ["Mark Glen Fletcher"]
  s.email       = ['f55d1d31@opayq.com']
  s.homepage    = 'https://github.com/markglenfletcher/irwick'
  s.required_ruby_version = '>= 2.1.0'

  s.files = Dir['lib/*.rb']
  s.files += Dir['lib/irwick/*.rb']
  s.files += Dir['lib/irwick/plugins/*.rb']
  s.files += Dir['bin/*']
  s.files += Dir['test/*.rb']
  s.files += Dir['config/*.json']

  s.executables << 'irwick'

  s.add_development_dependency 'minitest', '~> 5.4', '>= 5.4.2'
  s.add_development_dependency 'mocha', '~> 1.1', '>= 1.1.0'
end