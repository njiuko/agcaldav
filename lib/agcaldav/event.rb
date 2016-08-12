module AgCalDAV

  class Event
    class << self

      def find_multiple(client, starts: starts, ends: ends )
        events = []
        req = AgCalDAV::Request.new(:report, client)

        req.add_header(depth: "1", content_type: "application/xml")

        if starts.is_a? Integer
          req.add_body(AgCalDAV::XmlRequestBuilder::ReportVEVENT.new(Time.at(starts).utc.strftime("%Y%m%dT%H%M%S"),
                                                        Time.at(ends).utc.strftime("%Y%m%dT%H%M%S") ).to_xml)
        else
          req.add_body(AgCalDAV::XmlRequestBuilder::ReportVEVENT.new(Time.parse(starts).utc.strftime("%Y%m%dT%H%M%S"),
                                                        Time.parse(ends).utc.strftime("%Y%m%dT%H%M%S") ).to_xml)
        end
        
        req.run
      end

      def delete(client, uuid)
        req = AgCalDAV::Request.new(:delete, client, path: "#{uuid}.ics")

        req.run
      end

      def create_update(client, data)
        calendar = Icalendar::Calendar.new
        event = calendar.event do |e|
          e.dtstart      = DateTime.parse(data[:starts])
          e.dtend        = DateTime.parse(data[:ends])
          e.categories   = data[:categories]
          e.contact      = data[:contact]
          e.attendee     = data[:attendee]
          e.duration     = data[:duration]
          e.summary      = data[:title]
          e.description  = data[:description]
          e.transp       = data[:accessibility] #PUBLIC, PRIVATE, CONFIDENTIAL
          e.location     = data[:location]
          e.geo          = data[:geo_location]
          e.status       = data[:status]
          e.url          = data[:url]

          if data[:uid]
            e.uid = data[:uid]
          end
        end

        calendar_ical = calendar.to_ical
        req = AgCalDAV::Request.new(:put, client, path: "#{event.uid}.ics")

        req.add_header(content_type: "text/calendar")
        req.add_body(calendar_ical)

        if data[:etag]
          req.add_header(if_match: %Q/"#{data[:etag].gsub(/\A['"]+|['"]+\Z/, "")}"/)
        end

        req.run
      end
    end
  end
end
