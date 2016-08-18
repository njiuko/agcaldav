module SabredavClient

  class Principal
    attr_accessor :client

    def initialize(data)
      @client = SabredavClient::Client.new(data)
    end

    def create(email, displayname = nil)
      req = client.create_request(:mkcol)
      req.add_body(SabredavClient::XmlRequestBuilder::MkcolPrincipal.new(email, displayname).to_xml)
      req.add_header(content_type: "text/xml", depth: "1")

      res = req.run
      if res.code.to_i.between?(200,299)
        true
      else
        SabredavClient::Errors::errorhandling(res)
      end
    end

    def delete
      #FIXME seems like deleting a principal is forbidden by sabredav
      req = client.create_request(:delete)
      res = req.run

      if res.code.to_i.between?(200,299)
        true
      else
        SabredavClient::Errors::errorhandling(res)
      end
    end
  end
end
