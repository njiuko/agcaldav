module AgCalDAV

  class Calendar
    class << self

      def info(client)
        req = AgCalDAV::Request.new(:propfind, client)

        req.add_header(content_type: "application/xml")
        req.add_body(AgCalDAV::XmlRequestBuilder::PROPFINDCalendar.new(properties: [:displayname, :sync_token, :getctag]).to_xml)

        req.run
      end

      def create(client, displayname: "", description: "")
        req = AgCalDAV::Request.new(:mkcalendar, client)

        req.add_body(AgCalDAV::XmlRequestBuilder::Mkcalendar.new(displayname, description).to_xml)
        req.add_header(dav: "resource-must-be-null", content_type: "application/xml")

        req.run
      end

      def delete(client)
        req = AgCalDAV::Request.new(:delete, client)

        req.run
      end

      def share(client, data)
        req = AgCalDAV::Request.new(:post, client)

        req.add_body(AgCalDAV::XmlRequestBuilder::PostSharing.new(
          data[:adds],
          data[:summary],
          data[:common_name],
          data[:privilege],
          data[:removes]).to_xml)
        req.add_header(content_length: "xxxx", content_type: "application/xml")

        req.run
      end
    end
  end
end
