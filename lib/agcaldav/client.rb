module AgCalDAV
  class Client
    attr_reader :auth_type, :host, :port, :base_path, :user, :password, :ssl,
     :digest_auth, :duri, :proxy_host, :proxy_uri, :proxy_port

    def format=(fmt)
      @format = fmt
    end

    def format
      @format ||= Format::Debug.new
    end

    def initialize(data)
      unless data[:proxy_uri].nil?
        proxy_uri   = URI(data[:proxy_uri])
        @proxy_host = proxy_uri.host
        @proxy_port = proxy_uri.port.to_i
      end

      uri = URI(data[:uri])

      @host     = uri.host
      @port     = uri.port.to_i
      @base_path = uri.path
      @user     = data[:user]
      @password = data[:password]
      @ssl      = uri.scheme == 'https'

      unless data[:authtype].nil?
        @authtype = data[:authtype]

        if @authtype == 'digest'

          @digest_auth = Net::HTTP::DigestAuth.new
          @duri = URI.parse data[:uri]
          @duri.user = @user
          @duri.password = @password

        elsif @authtype == 'basic'
          #Don't Raise or do anything else
        else
          raise "Authentication Type Specified Is Not Valid. Please use basic or digest"
        end
      else
        @authtype = 'basic'
      end
    end

    def create_request(method, path: "")
      request = AgCalDAV::Request.new(method, self, path)
    end
  end
end
