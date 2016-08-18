require 'rspec'
require 'rubygems'
require 'sabredav_client'
require 'fakeweb'

RSpec.configure do |config|
  FakeWeb.allow_net_connect = false
end
