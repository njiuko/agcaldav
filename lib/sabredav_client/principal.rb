module SabredavClient

  class Principal
    attr_accessor :connection_config

    def initialize(data)
      @connection_config = SabredavClient::ConnectionConfig.new(data)
    end

    def create(email, displayname = nil)
      header  = {content_type: "text/xml", depth: "1"}
      body    = SabredavClient::XmlRequestBuilder::MkcolPrincipal.new(email, displayname).to_xml
      req     = SabredavClient::Request.new(connection_config, :mkcol, header: header, body: body)

      res = req.run
      if res.code.to_i.between?(200,299)
        true
      else
        SabredavClient::Errors::errorhandling(res)
      end
    end

    def update(email: "", displayname: "")
      header  = {content_type: "application/xml"}
      body    = SabredavClient::XmlRequestBuilder::ProppatchPrincipal.new(email, displayname).to_xml

      req     = SabredavClient::Request.new(connection_config, :proppatch, header: header, body: body)

      res     = req.run

      if res.code.to_i.between?(200,299)
        true
      else
        SabredavClient::Errors::errorhandling(res)
      end

    end

    def delete
      #FIXME seems like deleting a principal is forbidden by sabredav

      req     = SabredavClient::Request.new(connection_config, :delete)
      res = req.run

      if res.code.to_i.between?(200,299)
        true
      else
        SabredavClient::Errors::errorhandling(res)
      end
    end

  end
end
