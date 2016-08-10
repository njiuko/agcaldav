module AgCalDAV
  class Client
    attr_accessor :host, :port, :url, :user, :password, :ssl

    def format=( fmt )
      @format = fmt
    end

    def format
      @format ||= Format::Debug.new
    end

    def initialize( data )
      unless data[:proxy_uri].nil?
        proxy_uri   = URI(data[:proxy_uri])
        @proxy_host = proxy_uri.host
        @proxy_port = proxy_uri.port.to_i
      end

      uri = URI(data[:uri])
      @host     = uri.host
      @port     = uri.port.to_i
      @url      = uri.path
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

    def __create_http
      if @proxy_uri.nil?
        http = Net::HTTP.new(@host, @port)
      else
        http = Net::HTTP.new(@host, @port, @proxy_host, @proxy_port)
      end
      if @ssl
        http.use_ssl = @ssl
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      http
    end

    def info
      response = __create_http.start do |http|
        req = Net::HTTP::Propfind.new(@url, initheader = {'Content-Type'=>'application/xml'} )

        req.body = AgCalDAV::Request::PROPFINDCalendar.new(properties: [:displayname, :sync_token, :ctag]).to_xml

        add_auth("PROPFIND", req)

        http.request(req)
      end

      errorhandling response

      xml = REXML::Document.new(response.body)

      {
        displayname: REXML::XPath.first(xml, "//d:displayname").text,
        ctag: REXML::XPath.first(xml, "//cs:getctag").text
      }
    end

    def find_events(data)
      result = ""
      events = []
      res    = nil

      __create_http.start do |http|
        req = Net::HTTP::Report.new(@url, initheader = {'Content-Type'=>'application/xml'} )
        req["depth"] = 1
        add_auth("REPORT", req)

        if data[:start].is_a? Integer
          req.body = AgCalDAV::Request::ReportVEVENT.new(Time.at(data[:start]).utc.strftime("%Y%m%dT%H%M%S"),
                                                        Time.at(data[:end]).utc.strftime("%Y%m%dT%H%M%S") ).to_xml
        else
          req.body = AgCalDAV::Request::ReportVEVENT.new(Time.parse(data[:start]).utc.strftime("%Y%m%dT%H%M%S"),
                                                        Time.parse(data[:end]).utc.strftime("%Y%m%dT%H%M%S") ).to_xml
        end
        res = http.request(req)
      end

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

    def find_event uuid
      res = nil
      __create_http.start do |http|
        req = Net::HTTP::Get.new("#{@url}/#{uuid}.ics")

        add_auth("GET", req)

        res = http.request( req )
      end

      errorhandling res
      begin
        r = Icalendar::Calendar.parse(res.body)
      rescue
        return false
      else
        r.first.events.first
      end
    end

    def delete_event uuid
      res = nil

      __create_http.start do |http|
        req = Net::HTTP::Delete.new("#{@url}/#{uuid}.ics")

        add_auth("DELETE", req)

        res = http.request( req )
      end

      # accept any success code
      if res.code.to_i.between?(200,299)
        true
      else
        errorhandling(res)
      end
    end

    def set_event(data)
      calendar = Icalendar::Calendar.new

      event = calendar.event do |e|
        e.dtstart      = DateTime.parse(data[:start])
        e.dtend        = DateTime.parse(data[:end])
        e.categories   = data[:categories]
        e.contact      = data[:contact]
        e.attendee     = data[:attendee]
        e.duration     = data[:duration]
        e.summary      = data[:title]
        e.description  = data[:description]
        e.transp       = data[:accessibility] #PUBLIC, PRIVATE, CONFIDENTIAL
        e.location     = data[:location]
        e.geo          = data[:geo_location]
        e.status       = data[:status]
        e.url          = data[:url]

        if data[:uid]
          e.uid = data[:uid]
        end
      end

      calendar_ical = calendar.to_ical
      res           = nil
      http          = Net::HTTP.new(@host, @port)

      __create_http.start do |http|
        req                  = Net::HTTP::Put.new("#{@url}/#{event.uid}.ics")
        req['Content-Type']  = 'text/calendar'
        add_auth("PUT", req)
        req.body = calendar_ical

        if data[:etag]
          req['If-Match'] = %Q/"#{data[:etag].gsub(/\A['"]+|['"]+\Z/, "")}"/
        end
        res = http.request(req)
      end

      errorhandling(res)
      res['etag']
    end

    def create_calendar(data)
      res           = nil
      http          = Net::HTTP.new(@host, @port)

      __create_http.start do |http|
        req = Net::HTTP::Mkcalendar.new(@url, initheader = {'Content-Type'=>'application/xml'} )
        req.body = AgCalDAV::Request::Mkcalendar.new(data[:displayname], data[:description]).to_xml
        req['DAV'] = "resource-must-be-null"
        add_auth("MKCALENDAR", req)

        res = http.request(req)
      end

      errorhandling(res)
      info

    end

    def delete_calendar
      res = __create_http.start do |http|
        req = Net::HTTP::Delete.new(@url)
        add_auth("DELETE", req)

        res = http.request(req)
      end

      # accept any success code
      if res.code.to_i.between?(200,299)
        true
      else
        errorhandling(res)
      end
    end

    def manage_shares(data)
        res           = nil
        http          = Net::HTTP.new(@host, @port)

        raise TypeNotSupported if data[:type] && data[:type] != :email

        __create_http.start do |http|
          req = Net::HTTP::Post.new(@url, initheader = {'Content-Type'=>'application/xml'} )
          req.body = AgCalDAV::Request::PostSharing.new(
            data[:adds],
            data[:summary],
            data[:common_name],
            data[:privilege],
            data[:removes]).to_xml
          req['Content-Length'] = "xxxx"
          add_auth("POST", req)

          res = http.request(req)
        end

        if res.code.to_i.between?(200,299)
          true
        else
          errorhandling(res)
        end
      end

    private

    def add_auth(method, request)
      if not @authtype == 'digest'
        request.basic_auth @user, @password
      else
        request.add_field 'Authorization', digestauth(method)
      end
    end

    def digestauth method
      h = Net::HTTP.new @duri.host, @duri.port

      if @ssl
        h.use_ssl = @ssl
        h.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      req = Net::HTTP::Get.new @duri.request_uri
      res = h.request req
      # res is a 401 response with a WWW-Authenticate header

      auth = @digest_auth.auth_header @duri, res['www-authenticate'], method

      return auth
    end

    def entry_with_uuid_exists? uuid
      res = nil

      __create_http.start do |http|
        req = Net::HTTP::Get.new("#{@url}/#{uuid}.ics")

        add_auth("GET", req)

        res = http.request( req )
      end

      begin
        errorhandling res
        Icalendar::Calendar.parse(res.body)
      rescue
        return false
      end

      if res.code.to_i == 404
        false
      elsif res.code.to_i.between?(200,299)
        true
      end
    end

    def  errorhandling response
      case response.code.to_i
      when 401
        raise AuthenticationError
      when 404
        raise NotFoundError
      when 405
        raise NotAllowedError
      when 410
        raise NotExistError
      when 412
        raise PreconditionFailed
      when 500
        raise APIError
      end
    end
  end

  class AgCalDAVError < StandardError; end

  class TypeNotSupported    < AgCalDAVError; end
  class NotFoundError       < AgCalDAVError; end
  class PreconditionFailed  < AgCalDAVError; end
  class NotAllowedError     < AgCalDAVError; end
  class AuthenticationError < AgCalDAVError; end
  class DuplicateError      < AgCalDAVError; end
  class APIError            < AgCalDAVError; end
  class NotExistError       < AgCalDAVError; end
end
