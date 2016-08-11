module AgCalDAV

  class Request
    attr_accessor :request, :http
    attr_reader :client

    def initialize(method, client)
      @client = client
      @http         = init_http()
      @request      = init_request(method)
      add_auth()
    end

    def init_http()
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

    def init_request(method)
      raise StandardError unless method.is_a? Net::HTTPRequest
      method
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

    def add_auth
      unless client.auth_type == 'digest'
        request.basic_auth client.user, client.password
      else
        #FIXME method in line needs to be something like "PROPFIND" or other http methods  name strings
        #request.add_field 'Authorization', digestauth(method)
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
