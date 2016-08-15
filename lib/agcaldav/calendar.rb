module AgCalDAV

  class Calendar
    attr_accessor :client

    def initialize(data)
      @client = AgCalDAV::Client.new(data)
    end

    def events
      @events ||= AgCalDAV::Events.new(client)
    end

    def info
      req = client.create_request(:propfind)
      req.add_header(content_type: "application/xml")
      req.add_body(AgCalDAV::XmlRequestBuilder::PROPFINDCalendar.new(properties: [:displayname, :sync_token, :getctag]).to_xml)

      res = req.run

      AgCalDAV::Errors::errorhandling(res)

      xml = REXML::Document.new(res.body)

      {
        displayname: REXML::XPath.first(xml, "//d:displayname").text,
        ctag: REXML::XPath.first(xml, "//cs:getctag").text
      }
    end

    def create(displayname: "", description: "")
      req = client.create_request(:mkcalendar)
      req.add_body(AgCalDAV::XmlRequestBuilder::Mkcalendar.new(displayname, description).to_xml)
      req.add_header(dav: "resource-must-be-null", content_type: "application/xml")

      res = req.run

      AgCalDAV::Errors.errorhandling(res)
      info
    end

    def delete
      req = client.create_request(:delete)
      res = req.run

      if res.code.to_i.between?(200,299)
        true
      else
        AgCalDAV::Errors::errorhandling(res)
      end
    end

    def share(adds: [], removes: [], summary: nil, common_name: nil,
      privilege: "write-read", type: nil)
      req = client.create_request(:post)
      req.add_body(AgCalDAV::XmlRequestBuilder::PostSharing.new(
        adds, summary, common_name, privilege, removes).to_xml)
      req.add_header(content_length: "xxxx", content_type: "application/xml")

      res = req.run

      raise AgCalDAV::Errors::ShareeTypeNotSupportedError if type && type != :email

      if res.code.to_i.between?(200,299)
        true
      else
        AgCalDAV::Errors::errorhandling(res)
      end
    end
  end
end
