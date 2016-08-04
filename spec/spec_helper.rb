require 'rspec'
require 'rubygems'
require 'agcaldav'
require 'fakeweb'

RSpec.configure do |config|
  FakeWeb.allow_net_connect = false
end
