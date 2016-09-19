module SabredavClient

  class Events
    attr_accessor :client

    def initialize(client)
      @client = client
    end

    def find(uri)
      req = client.create_request(:get, path: uri)
      res = req.run

      SabredavClient::Errors::errorhandling(res)

      etag = res.header["etag"]
      etag = %Q/#{etag.gsub(/\A['"]+|['"]+\Z/, "")}/ unless etag.nil?

      {
        ics: res.body,
        etag: etag
      }
    end

    def find_multiple(starts: "", ends: "")
      events  = []
      header  = {depth: "1", content_type: "application/xml"}

      if starts.is_a? Integer
        body = SabredavClient::XmlRequestBuilder::ReportVEVENT.new(Time.at(starts).utc.strftime("%Y%m%dT%H%M%S"),
                                                      Time.at(ends).utc.strftime("%Y%m%dT%H%M%S") ).to_xml
      else
        body = SabredavClient::XmlRequestBuilder::ReportVEVENT.new(Time.parse(starts).utc.strftime("%Y%m%dT%H%M%S"),
                                                      Time.parse(ends).utc.strftime("%Y%m%dT%H%M%S") ).to_xml
      end

      req = client.create_request(:report, header: header)
      res = req.run

      SabredavClient::Errors::errorhandling(res)
      result = ""

      xml = REXML::Document.new(res.body)
      REXML::XPath.each( xml, '//c:calendar-data/', {"c"=>"urn:ietf:params:xml:ns:caldav"} ){|c| result << c.text}

      result
    end

    def owner(uri)
      # Warning: This is not a standard request. It only works if your sabredav
      # server uses a certain OwnerPlugin
      header = {content_type: "application/xml"}
      body = XmlRequestBuilder::PropfindOwner.new.to_xml
      req = client.create_request(:propfind, path: uri, header: header, body: body)
      res = req.run

      SabredavClient::Errors::errorhandling(res)
      xml = REXML::Document.new(res.body)
      REXML::XPath.first(xml, "//cs:objectOwner").text
    end

    def update_owner(uri, owner)
      # Warning: This is not a standard request. It only works if your sabredav
      # server uses a certain OwnerPlugin
      header = {content_type: "application/xml"}
      body = XmlRequestBuilder::ProppatchEventsOwner.new(owner).to_xml
      req = client.create_request(:proppatch, path: uri, header: header, body: body)
      res = req.run

      if res.code.to_i.between?(200,299)
        true
      else
        SabredavClient::Errors::errorhandling(res)
      end
    end

    def delete(uri)
      raise SabredavClient::Errors::SabredavClientError if uri.nil? || !uri.end_with?(".ics")

      req = client.create_request(:delete, path: uri)
      res = req.run

      if res.code.to_i.between?(200,299)
        true
      else
        SabredavClient::Errors::errorhandling(res)
      end
    end

    def create_update(uri, event_ics, etag = nil)
      header  = {content_type: "text/calendar"}
      body    = event_ics

      if etag
        header[:if_match] = %Q/"#{etag.gsub(/\A['"]+|['"]+\Z/, "")}"/
      end

      req = client.create_request(:put,header: header, body: body, path: uri)
      res = req.run

      SabredavClient::Errors::errorhandling(res)
      etag = res['etag']
      %Q/#{etag.gsub(/\A['"]+|['"]+\Z/, "")}/ unless etag.nil?
    end
  end
end
