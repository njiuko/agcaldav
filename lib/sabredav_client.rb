require 'net/https'
require 'net/http/digest_auth'
require 'rexml/document'
require 'rexml/xpath'
require 'time'
require 'date'

['errors/errors.rb','xml_request_builder.rb', 'client.rb', 'request.rb', 'net.rb', "calendar.rb", "events.rb", "principal.rb"].each do |f|
    require File.join( File.dirname(__FILE__), 'sabredav_client', f )
end
