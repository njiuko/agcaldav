require 'net/https'
require 'net/http/digest_auth'
require 'uuid'
require 'rexml/document'
require 'rexml/xpath'
require 'icalendar'
require 'time'
require 'date'

['client.rb','xml_request_builder.rb', 'net.rb', 'query.rb', 'filter.rb', 'format.rb'].each do |f|
    require File.join( File.dirname(__FILE__), 'agcaldav', f )
end
