module AgCalDAV
  class Client
    attr_reader :auth_type, :host, :port, :base_path, :user, :password, :ssl,
     :digest_auth, :duri, :proxy_host, :proxy_uri, :proxy_port

    def format=( fmt )
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

    def info
      res = AgCalDAV::Calendar.info(self)

      errorhandling res

      xml = REXML::Document.new(res.body)

      {
        displayname: REXML::XPath.first(xml, "//d:displayname").text,
        ctag: REXML::XPath.first(xml, "//cs:getctag").text
      }
    end

    def find_events(data)
      res = AgCalDAV::Event.find_multiple(self, data)

      errorhandling res
      result = ""

      xml = REXML::Document.new(res.body)
      REXML::XPath.each( xml, '//c:calendar-data/', {"c"=>"urn:ietf:params:xml:ns:caldav"} ){|c| result << c.text}

      calendar = Icalendar::Calendar.parse(result).first
      if calendar
        calendar.events
      else
        false
      end
    end

    def find_event uid
      req = AgCalDAV::Request.new(:get, self, path: "#{uid}.ics")
      res = req.run

      errorhandling res
      begin
        r = Icalendar::Calendar.parse(res.body)
      rescue
        return false
      else
        r.first.events.first
      end
    end

    def delete_event uid
      res = AgCalDAV::Event.delete(self, uid)

      if res.code.to_i.between?(200,299)
        true
      else
        errorhandling(res)
      end
    end

    def create_update_event(data)
      res = AgCalDAV::Event.create_update(self, data)

      errorhandling(res)
      res['etag']
    end

    def create_calendar(data)
      res = AgCalDAV::Calendar.create(self, data)
      errorhandling(res)
      info
    end

    def delete_calendar
      res = AgCalDAV::Calendar.delete(self)
      if res.code.to_i.between?(200,299)
        true
      else
        errorhandling(res)
      end
    end

    def manage_shares(data)
        raise AgCalDAV::Errors::ShareeTypeNotSupportedError if data[:type] && data[:type] != :email

        res = AgCalDAV::Calendar.share(self, data)

        if res.code.to_i.between?(200,299)
          true
        else
          errorhandling(res)
        end
      end

    private

    def  errorhandling response
      case response.code.to_i
      when 401
        raise AgCalDAV::Errors::AuthenticationError
      when 404
        raise AgCalDAV::Errors::NotFoundError
      when 405
        raise AgCalDAV::Errors::NotAllowedError
      when 410
        raise AgCalDAV::Errors::NotExistError
      when 412
        raise AgCalDAV::Errors::PreconditionFailed
      when 500
        raise AgCalDAV::Errors::APIError
      end
    end
  end
end
