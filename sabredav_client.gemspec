# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require File.expand_path('../lib/sabredav_client/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "sabredav_client"
  s.version     = SabredavClient::VERSION
  s.summary     = "Ruby SabreDAV client"
  s.description = "A great Ruby client for SabreDAV Servers."

  s.required_ruby_version     = '>= 1.9.2'

  s.license     = 'MIT'

  s.homepage    = %q{https://github.com/njiuko/sabredav_client}
  s.authors     = [%q{Nicolas Schwartau}]
  s.email       = [%q{n.schwartau@gmail.com}]

  s.add_runtime_dependency 'builder', '~> 3.2'
  s.add_runtime_dependency 'net-http-digest_auth', '~> 1.4'

  s.add_development_dependency 'rspec', '~> 3.5'
  s.add_development_dependency 'fakeweb', '~> 1.3'

  s.description = <<-DESC
  sabredav_client is a great Ruby client for SabreDAV servers.  It is based on the agcaldav gem.
DESC

  s.files         = `git ls-files`.split("\n")
  s.require_paths = ["lib"]
end
