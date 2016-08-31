module SabredavClient

  class Calendar
    attr_accessor :client

    def initialize(data)
      @client = SabredavClient::Client.new(data)
    end

    def events
      @events ||= SabredavClient::Events.new(client)
    end

    def info
      header  = {content_type: "application/xml"}
      body    = SabredavClient::XmlRequestBuilder::PROPFINDCalendar.new(properties: [:displayname, :sync_token, :getctag]).to_xml

      req = client.create_request(:propfind, header: header, body: body)
      res = req.run

      SabredavClient::Errors::errorhandling(res)

      xml = REXML::Document.new(res.body)
      {
        displayname: REXML::XPath.first(xml, "//d:displayname").text,
        ctag: REXML::XPath.first(xml, "//cs:getctag").text,
        sync_token: REXML::XPath.first(xml, "//d:sync-token").text
      }
    end

    def create(displayname: "", description: "")
      body    = SabredavClient::XmlRequestBuilder::Mkcalendar.new(displayname, description).to_xml
      header  = {dav: "resource-must-be-null", content_type: "application/xml"}

      req = client.create_request(:mkcalendar, header: header, body: body)

      res = req.run

      SabredavClient::Errors.errorhandling(res)
      info
    end

    def update(displayname: nil, description: nil)
      body = XmlRequestBuilder::ProppatchCalendar.new(displayname, description).to_xml
      header = {content_type: "application/xml"}

      req = client.create_request(:proppatch, header: header, body: body)

      res = req.run

      if res.code.to_i.between?(200,299)
        true
      else
        SabredavClient::Errors::errorhandling(res)
      end
    end

    def delete
      req = client.create_request(:delete)
      res = req.run

      if res.code.to_i.between?(200,299)
        true
      else
        SabredavClient::Errors::errorhandling(res)
      end
    end

    def share(adds: [], removes: [], summary: nil, common_name: nil,
      privilege: "write-read", type: nil)

      header  = {content_length: "xxxx", content_type: "application/xml"}
      body    = SabredavClient::XmlRequestBuilder::PostSharing.new(
        adds, summary, common_name, privilege, removes).to_xml

      req = client.create_request(:post, header: header, body: body)

      res = req.run

      raise SabredavClient::Errors::ShareeTypeNotSupportedError if type && type != :email

      if res.code.to_i.between?(200,299)
        true
      else
        SabredavClient::Errors::errorhandling(res)
      end
    end

    def fetch_sharees
      body    = SabredavClient::XmlRequestBuilder::PropfindInvite.new.to_xml
      header  = {content_type: "application/xml", depth: "0"}

      req     = client.create_request(:propfind, header: header, body: body)

      res     = req.run

      SabredavClient::Errors::errorhandling(res)

      sharees   = []
      xml       = REXML::Document.new(res.body)

      REXML::XPath.each(xml, "//cs:user/", {"cs"=> "http://calendarserver.org/ns/"}) do |user|
        entry = REXML::Document.new.add(user)
        sharee = {
          href:           REXML::XPath.first(entry, "//d:href").text,
        }
        access          = REXML::XPath.first(entry, "//d:access").elements[1].to_s
        sharee[:access] = access.gsub(/\A[<cs:]+|[\/>]+\Z/, "")

        # So far Sabredav accepts every invite by default
        sharee[:status] = !REXML::XPath.first(entry, "//cs:invite-accepted").nil? ? :accepted : nil

        sharee[:common_name] = !REXML::XPath.first(entry, "//d:common-name").nil? ? REXML::XPath.first(entry, "//d:common-name").text : nil

        # URI depends on a custom plugin
        sharee[:uri] = !REXML::XPath.first(entry, "//cs:uri").nil? ? REXML::XPath.first(entry, "//cs:uri").text : nil

        # URI depends on a custom plugin
        sharee[:principal] = !REXML::XPath.first(entry, "//cs:principal").nil? ? REXML::XPath.first(entry, "//cs:principal").text : nil

        sharees.push(sharee)
      end

      {
        sharees: sharees,
        organizer: {
                    href: REXML::XPath.first(xml, "//cs:organizer").elements[2].text,
                    uri:  REXML::XPath.first(xml, "//cs:uri").text
                  }
      }

    end

    def fetch_changes(sync_token)

      body    = SabredavClient::XmlRequestBuilder::ReportEventChanges.new(sync_token).to_xml
      header  = {content_type: "application/xml"}

      req     = client.create_request(:report, header: header, body: body)

      res     = req.run

      SabredavClient::Errors::errorhandling(res)

      changes   = []
      deletions = []
      xml = REXML::Document.new(res.body)

      #FIXME This is so damn ugly, but at least it`s working now
      REXML::XPath.each(xml, "//d:response/", {"d"=> "DAV:"}) do |response|
        entry = REXML::Document.new.add(response)
        if (REXML::XPath.first(entry, "//d:status").text == "HTTP/1.1 404 Not Found")
            deletions.push(
              REXML::XPath.first(entry, "//d:href").text.to_s.split("/").last)
        else
          changes.push(
            {
              uri:  REXML::XPath.first(entry, "//d:href").text.split("/").last,
              etag: REXML::XPath.first(entry, "//d:getetag").text
            })
        end
      end

      {
        changes: changes,
        deletions: deletions,
        sync_token: REXML::XPath.first(xml, "//d:sync-token").text
      }
    end
  end
end
