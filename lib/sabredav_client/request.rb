module SabredavClient
  class Request

    attr_reader :connection_config, :request, :http

    def initialize(connection_config, method, header: {}, body: "", path: "")

      @connection_config  = connection_config
      @http    = build_http
      @request = build_request(method, "#{connection_config.base_path}/#{path}")
      add_header(header)  unless header.empty?
      add_body(body)      unless body.empty?

      add_auth
    end

    def add_body(body)
      request.body = body
    end

    def add_header(data)
      request['Content-Length']  = data[:content_length]  if data[:content_length]
      request['If-Match']        = data[:if_match]        if data[:if_match]
      request['Content-Type']    = data[:content_type]    if data[:content_type]
      request['DAV']             = data[:dav]             if data[:dav]
    end

    def run
      @http.request(request)
    end

    private

    def build_http
      unless connection_config.proxy_uri
        http = Net::HTTP.new(connection_config.host, connection_config.port)
      else
        http = Net::HTTP.new(connection_config.host, connection_config.port, connection_config.proxy_host, connection_config.proxy_port)
      end

      if connection_config.ssl
        http.use_ssl = connection_config.ssl
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      http
    end

    def build_request(method, path)
      case method
      when :get
        Net::HTTP::Get.new(path)
      when :post
        Net::HTTP::Post.new(path)
      when :put
        Net::HTTP::Put.new(path)
      when :delete
        Net::HTTP::Delete.new(path)
      when :propfind
        Net::HTTP::Propfind.new(path)
      when :proppatch
        Net::HTTP::Proppatch.new(path)
      when :report
        Net::HTTP::Report.new(path)
      when :mkcalendar
        Net::HTTP::Mkcalendar.new(path)
      when :mkcol
        Net::HTTP::Mkcol.new(path)
      else
        raise SabredavClient::Errors::HTTPMethodNotSupportedError, method
      end
    end

    def add_auth
      unless connection_config.authtype == 'digest'
        request.basic_auth connection_config.user, connection_config.password
      else
        request.add_field 'Authorization', digestauth(method.to_s.upcase)
      end
    end

    def digestauth
      h = Net::HTTP.new connection_config.duri.host, connection_config.duri.port

      if connection_config.ssl
        h.use_ssl = connection_config.ssl
        h.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      req = Net::HTTP::Get.new connection_config.duri.request_uri
      res = h.request req
      # res is a 401 response with a WWW-Authenticate header

      auth = connection_config.digest_auth.auth_header connection_config.duri, res['www-authenticate'], method

      return auth
    end
  end
end
