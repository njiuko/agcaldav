module SabredavClient

  class Events
    attr_accessor :client

    def initialize(client)
      @client = client
    end

    def find(uid)
      req = client.create_request(:get, path: "#{uid}.ics")
      res = req.run

      SabredavClient::Errors::errorhandling(res)
      begin
        r = Icalendar::Calendar.parse(res.body)
      rescue
        return false
      else
        r.first.events.first
      end
    end

    def find_multiple(starts: "", ends: "")
      events = []
      req = client.create_request(:report)
      req.add_header(depth: "1", content_type: "application/xml")
      if starts.is_a? Integer
        req.add_body(SabredavClient::XmlRequestBuilder::ReportVEVENT.new(Time.at(starts).utc.strftime("%Y%m%dT%H%M%S"),
                                                      Time.at(ends).utc.strftime("%Y%m%dT%H%M%S") ).to_xml)
      else
        req.add_body(SabredavClient::XmlRequestBuilder::ReportVEVENT.new(Time.parse(starts).utc.strftime("%Y%m%dT%H%M%S"),
                                                      Time.parse(ends).utc.strftime("%Y%m%dT%H%M%S") ).to_xml)
      end

      res = req.run

      SabredavClient::Errors::errorhandling(res)
      result = ""

      xml = REXML::Document.new(res.body)
      REXML::XPath.each( xml, '//c:calendar-data/', {"c"=>"urn:ietf:params:xml:ns:caldav"} ){|c| result << c.text}

      calendar = Icalendar::Calendar.parse(result).first
      if calendar
        calendar.events
      else
        false
      end
    end

    def delete(uuid)
      req = client.create_request(:delete, path: "#{uuid}.ics")

      res = req.run

      if res.code.to_i.between?(200,299)
        true
      else
        SabredavClient::Errors::errorhandling(res)
      end
    end

    def create_update(uri, event_ics, etag = nil)

      req = client.create_request(:put, path: uri)
      req.add_header(content_type: "text/calendar")
      req.add_body(event_ics)
      if etag
        req.add_header(if_match: %Q/"#{etag.gsub(/\A['"]+|['"]+\Z/, "")}"/)
      end

      res = req.run

      SabredavClient::Errors::errorhandling(res)
      res['etag']
    end
  end
end
