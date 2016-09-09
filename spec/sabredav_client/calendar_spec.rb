require 'spec_helper'

describe SabredavClient::Calendar do

  let(:calendar) { SabredavClient::Calendar.new(:uri => "http://localhost:5232/user/calendar", :user => "user" , :password => "") }

  describe "initialization" do

    it "check Class of new calendar" do
      expect(calendar).to be_a(SabredavClient::Calendar)
    end

    it "request configuration is available" do
      expect(calendar.client).to be_a(SabredavClient::Client)
    end

  end

  describe "events" do

    it "events returns Events class" do
      expect(calendar.events).to be_a(SabredavClient::Events)
    end
  end

  describe "calendar" do

    it "create" do
      displayname = "Test Calendar"
      ctag        = "http://sabre.io/ns/sync/15"
      sync_token  = ctag

      FakeWeb.register_uri(:mkcalendar, %r{http://user@localhost:5232/user/calendar}, status: ["201", "Created"])
      FakeWeb.register_uri(:propfind, %r{http://user@localhost:5232/user/calendar}, status: ["200", "OK"], body: File.open("spec/fixtures/calendar_info.xml"))

      r = calendar.create(displayname: displayname)

      expect(r[:displayname]).to eq(displayname)
      expect(r[:ctag]).to        eq(ctag)
      expect(r[:sync_token]).to  eq(sync_token)
    end

    it "update" do
      description = "a example description"
      displayname = "example discription"
      body        = SabredavClient::XmlRequestBuilder::ProppatchCalendar.new(displayname, description).to_xml
      header      = {content_type: "application/xml"}

      FakeWeb.register_uri(:proppatch, "http://user@localhost:5232/user/calendar/", status: ["207", "Multi-Status"])

      expect(calendar.client).to receive(:create_request).with(:proppatch, header: header, body: body).and_call_original

      r = calendar.update(displayname: displayname, description: description)
      expect(r).to be

    end

    it "delete" do
      FakeWeb.register_uri(:delete, "http://user@localhost:5232/user/calendar/",
                                    [{status: ["204", "No Content"]}, {status: ["404", "Not Found"]}])
      r = calendar.delete
      expect(r).to be(true)

      expect {
        calendar.delete
      }.to raise_error(SabredavClient::Errors::NotFoundError)
    end
  end

  describe "sharing" do
    FakeWeb.register_uri(:post, "http://user@localhost:5232/user/calendar/", [{status: ["200", "OK"]},
                                                                             {status: ["200", "OK"]}])
    it "is type email" do
      type = :email
      r = calendar.share adds: ["test@test.de"], privilege: "write-read"
      expect(r).to be(true)
    end

    it "is not type email" do
      type = :other
      expect {
        calendar.share adds: ["test@test.de"], privilege: "write-read", type: type
      }.to raise_error(SabredavClient::Errors::ShareeTypeNotSupportedError)
    end

    it "add one share" do
      r = calendar.share(adds: ["test@test.de"], privilege: "write-read")
      expect(r).to be(true)
    end

    it "fetch_sharees" do
      FakeWeb.register_uri(:propfind, "http://user@localhost:5232/user/calendar/", body: File.open('spec/fixtures/calendar_sharees.xml') )

      organizer = {href: "/caldav/server.php/principals/user", uri: "D8D498E2-4A98-4DC7-B421-BC49261168AF"}
      sharees =
        [{href: "mailto:sharee1@njiuko.com", common_name: "sharee1", access: "read", status: :accepted, uri: "5bffa09e-7220-4688-a13f-088714a98783", principal: nil},
          {href: "mailto:sharee2@protonet.info", common_name: "sharee2", access: "write-read", status: :accepted, uri: "f176b400-f0e4-4a57-bd92-0c307810ce12", principal: nil}]
      expected_result = {sharees: sharees, organizer: organizer}

      r = calendar.fetch_sharees
      expect(r).to eq(expected_result)
    end

    context "errors" do
      it "deals with missing common name" do
        FakeWeb.register_uri(:propfind, "http://user@localhost:5232/user/calendar/", body: File.open('spec/fixtures/calendar_sharees_without_common_name.xml') )

        organizer = {href: "/caldav/server.php/principals/user", uri: "D8D498E2-4A98-4DC7-B421-BC49261168AF"}
        sharees = [{href: "mailto:sharee2@protonet.info", common_name: nil, access: "write-read", status: :accepted, uri: "f176b400-f0e4-4a57-bd92-0c307810ce12", principal: "principal/user99"}]
        expected_result = {sharees: sharees, organizer: organizer}

        r = calendar.fetch_sharees
        expect(r).to eq(expected_result)
      end
    end
  end

  describe "info" do
    it "fetches the calendar info" do
      FakeWeb.register_uri(:propfind, "http://user@localhost:5232/user/calendar/", body: File.open('spec/fixtures/calendar_info.xml') )
      info = calendar.info

      expect(info[:displayname]).to eq("Test Calendar")
      expect(info[:ctag]).to eq("http://sabre.io/ns/sync/15")
    end
  end

  describe "fetch changes" do
    new_sync_token  = "http://sabredav.org/ns/sync/5001"
    deletions       = [ "deletedevent.ics" ]
    changes         = [ {uri: "newevent.ics", etag: "\"1\""}, {uri: "updatedevent.ics", etag: "\"2\""}]

    it "got two changes and one deletion" do
      FakeWeb.register_uri(:report, "http://user@localhost:5232/user/calendar/", body: File.open('spec/fixtures/calendar_fetch_changes.xml') )
      result = calendar.fetch_changes("random_token")
      expect(result[:deletions]).to eq deletions
      expect(result[:changes]).to eq changes
      expect(result[:sync_token]).to eq new_sync_token
    end
  end

end
