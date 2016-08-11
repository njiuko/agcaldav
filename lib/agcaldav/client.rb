module AgCalDAV
  class Client
    attr_reader :auth_type, :host, :port, :url, :user, :password, :ssl,
     :digest_auth, :duri, :proxy_host, :proxy_uri, :proxy_port

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

    def info
      req = AgCalDAV::Request.new(Net::HTTP::Propfind.new(@url), self)

      req.add_header(content_type: "application/xml")
      req.add_body(AgCalDAV::XmlRequestBuilder::PROPFINDCalendar.new(properties: [:displayname, :sync_token, :getctag]).to_xml)

      res = req.run

      errorhandling res

      xml = REXML::Document.new(res.body)

      {
        displayname: REXML::XPath.first(xml, "//d:displayname").text,
        ctag: REXML::XPath.first(xml, "//cs:getctag").text
      }
    end

    def find_events(data)

      events = []
      req = AgCalDAV::Request.new(Net::HTTP::Report.new(@url), self)
      req.add_header(depth: "1", content_type: "application/xml")

      if data[:start].is_a? Integer
        req.add_body(AgCalDAV::XmlRequestBuilder::ReportVEVENT.new(Time.at(data[:start]).utc.strftime("%Y%m%dT%H%M%S"),
                                                      Time.at(data[:end]).utc.strftime("%Y%m%dT%H%M%S") ).to_xml)
      else
        req.add_body(AgCalDAV::XmlRequestBuilder::ReportVEVENT.new(Time.parse(data[:start]).utc.strftime("%Y%m%dT%H%M%S"),
                                                      Time.parse(data[:end]).utc.strftime("%Y%m%dT%H%M%S") ).to_xml)
      end
      res = req.run

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
      req = AgCalDAV::Request.new(Net::HTTP::Get.new("#{@url}/#{uuid}.ics"), self)
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

    def delete_event uuid
      req = AgCalDAV::Request.new(Net::HTTP::Delete.new("#{@url}/#{uuid}.ics"), self)
      res = req.run

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

      req                  = AgCalDAV::Request.new(Net::HTTP::Put.new("#{@url}/#{event.uid}.ics"), self)
      req.add_header(content_type: "text/calendar")
      req.add_body(calendar_ical)

      if data[:etag]
        req.add_header(if_match: %Q/"#{data[:etag].gsub(/\A['"]+|['"]+\Z/, "")}"/)
      end
      res = req.run

      errorhandling(res)
      res['etag']
    end

    def create_calendar(data)
      req = AgCalDAV::Request.new(Net::HTTP::Mkcalendar.new(@url), self)
      req.add_body(AgCalDAV::XmlRequestBuilder::Mkcalendar.new(data[:displayname], data[:description]).to_xml)
      req.add_header(dav: "resource-must-be-null", content_type: "application/xml")
      res = req.run

      errorhandling(res)
      info
    end

    def delete_calendar
      req = AgCalDAV::Request.new(Net::HTTP::Delete.new(@url), self)
      res = req.run

      # accept any success code
      if res.code.to_i.between?(200,299)
        true
      else
        errorhandling(res)
      end
    end

    def manage_shares(data)

        raise AgCalDAV::Errors::TypeNotSupportedError if data[:type] && data[:type] != :email

        req = AgCalDAV::Request.new(Net::HTTP::Post.new(@url), self)
        req.add_body(AgCalDAV::XmlRequestBuilder::PostSharing.new(
          data[:adds],
          data[:summary],
          data[:common_name],
          data[:privilege],
          data[:removes]).to_xml)
        req.add_header(content_length: "xxxx", content_type: "application/xml")

        res = req.run

        if res.code.to_i.between?(200,299)
          true
        else
          errorhandling(res)
        end
      end

    private

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
