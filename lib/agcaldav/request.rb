module AgCalDAV
  class Request
    attr_accessor :path
    attr_reader :client, :request, :http

    def initialize(method, client, path)
      @client  = client
      @path    = "#{client.base_path}/#{path}"
      @http    = build_http
      @request = build_request(method)

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
      unless client.proxy_uri
        http = Net::HTTP.new(client.host, client.port)
      else
        http = Net::HTTP.new(client.host, client.port, client.proxy_host, client.proxy_port)
      end

      if client.ssl
        http.use_ssl = client.ssl
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      http
    end

    def build_request(method)
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
      when :report
        Net::HTTP::Report.new(path)
      when :mkcalendar
        Net::HTTP::Mkcalendar.new(path)
      when :mkcol
        Net::HTTP::Mkcol.new(path)
      else
        raise AgCalDAV::Errors::HTTPMethodNotSupportedError, method
      end
    end

    def add_auth
      unless client.auth_type == 'digest'
        request.basic_auth client.user, client.password
      else
        request.add_field 'Authorization', digestauth(method.to_s.upcase)
      end
    end

    def digestauth
      h = Net::HTTP.new client.duri.host, client.duri.port

      if client.ssl
        h.use_ssl = client.ssl
        h.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      req = Net::HTTP::Get.new client.duri.request_uri
      res = h.request req
      # res is a 401 response with a WWW-Authenticate header

      auth = client.digest_auth.auth_header client.duri, res['www-authenticate'], method

      return auth
    end
  end
end
