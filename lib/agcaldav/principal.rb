module AgCalDAV

  class Principal
    attr_accessor :client

    def initialize(data)
      @client = AgCalDAV::Client.new(data)
    end

    def create(email, displayname = nil)
      req = client.create_request(:mkcol)
      req.add_body(AgCalDAV::XmlRequestBuilder::MkcolPrincipal.new(email, displayname).to_xml)
      req.add_header(content_type: "text/xml", depth: "1")

      res = req.run
      puts res.code
      if res.code.to_i.between?(200,299)
        true
      else
        AgCalDAV::Errors::errorhandling(res)
      end
    end

    def delete
      #FIXME seems like deleting a principal is forbidden by sabredav
      req = client.create_request(:delete)
      res = req.run

      if res.code.to_i.between?(200,299)
        true
      else
        AgCalDAV::Errors::errorhandling(res)
      end
    end
  end
end
