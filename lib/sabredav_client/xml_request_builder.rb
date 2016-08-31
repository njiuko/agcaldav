require 'builder'

['base.rb', 'propfind_calendar.rb', 'mkcalendar.rb', 'post_sharing.rb', 'report_vevent.rb', 'report_vtodo.rb', 'mkcol_principal.rb',
'report_event_changes.rb', 'propfind_owner.rb', 'proppatch_events_owner.rb', 'propfind_invite.rb', 'proppatch_principal.rb',
'proppatch_calendar.rb'].each do |f|
    require File.join( File.dirname(__FILE__), 'xml_request_builder', f )
end
