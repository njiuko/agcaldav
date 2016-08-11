require 'spec_helper'

describe AgCalDAV::Client do
  before(:each) do
    @c = AgCalDAV::Client.new(:uri => "http://localhost:5232/user/calendar", :user => "user" , :password => "")
  end

  it "check Class of new calendar" do
    expect(@c.class.to_s).to eq("AgCalDAV::Client")
  end

  describe "calendar" do

    it "create calendar" do
      FakeWeb.register_uri(:mkcalendar, %r{http://user@localhost:5232/user/calendar}, status: ["201", "Created"])
      FakeWeb.register_uri(:propfind, %r{http://user@localhost:5232/user/calendar}, status: ["200", "ok"], body: File.open("spec/fixtures/calendar_info.xml"))

      r = @c.create_calendar(displayname: "Test Calendar")
      expect(r).to be
    end

    it "delete calendar" do
      FakeWeb.register_uri(:delete, "http://user@localhost:5232/user/calendar",
                                    [{status: ["204", "No Content"]}, {status: ["404", "Not Found"]}])
      r = @c.delete_calendar
      expect(r).to be (true)

      expect {
        @c.delete_calendar
      }.to raise_error(AgCalDAV::NotFoundError)
    end
  end

  describe "set_event" do
    let(:uid) { UUID.new.generate }
    #let(:event) { "BEGIN:VCALENDAR\nPRODID:-//Radicale//NONSGML Radicale Server//EN\nVERSION:2.0\nBEGIN:VEVENT\nDESCRIPTION:12345 12ss345\nDTEND:20130101T110000\nDTSTAMP:20130101T161708\nDTSTART:20130101T100000\nSEQUENCE:0\nSUMMARY:123ss45\nUID:#{uid}\nX-RADICALE-NAME:#{uid}.ics\nEND:VEVENT\nEND:VCALENDAR" }
    let(:etag) { "123" }

    it "create one event" do
      allow(SecureRandom).to receive(:uuid).and_return(uid)
      FakeWeb.register_uri(:put, %r{http://user@localhost:5232/user/calendar/#{uid}.ics}, {etag: etag, status: ["201", "OK"]})

      r = @c.set_event(:start => "2012-12-29 10:00", :end => "2012-12-30 12:00", :title => "12345", :description => "12345 12345")
      expect(r).to eq etag
    end

    it "update one event" do
      new_etag = "124"
      FakeWeb.register_uri(:put, "http://user@localhost:5232/user/calendar/#{uid}.ics", {status: ["200", "OK"], etag: new_etag})

      r = @c.set_event(:start => "2012-12-29 10:00", :end => "2012-12-30 12:00", :title => "Updated", :description => "12345 12345", etag: etag, uid: uid )
      expect(r).not_to eq etag
    end
  end

  describe "manage_shares" do
    FakeWeb.register_uri(:post, "http://user@localhost:5232/user/calendar", [{status: ["200", "OK"]},
                                                                             {status: ["200", "OK"]}])
    it "is type email" do
      type = :email
      r = @c.manage_shares adds: ["test@test.de"], privilege: "write-read"
      expect(r).to be(true)
    end

    it "is not type email" do
      type = :other
      expect {
        @c.manage_shares adds: ["test@test.de"], privilege: "write-read", type: type
      }.to raise_error(AgCalDAV::TypeNotSupported)
    end

    it "add one share" do
      #TODO
    end
  end

  it "delete one event" do
    uid = UUID.new.generate
    FakeWeb.register_uri(:delete, %r{http://user@localhost:5232/user/calendar/(.*).ics},
                         [{:body => "1 deleted.", :status => ["200", "OK"]},
                          {:body => "not found",  :status => ["404", "Not Found"]}])
    r = @c.delete_event(uid)
    expect(r).to be(true)
    expect {
      @c.delete_event(uid)
    }.to raise_error(AgCalDAV::NotFoundError)
  end

  it "find one event" do
    uid = "5385e2d0-3707-0130-9e49-001999638982"
    FakeWeb.register_uri(:get, "http://user@localhost:5232/user/calendar/#{uid}.ics", :body => "BEGIN:VCALENDAR\nPRODID:-//Radicale//NONSGML Radicale Server//EN\nVERSION:2.0\nBEGIN:VEVENT\nDESCRIPTION:12345 12ss345\nDTEND:20130101T110000\nDTSTAMP:20130101T161708\nDTSTART:20130101T100000\nSEQUENCE:0\nSUMMARY:123ss45\nUID:#{uid}\nX-RADICALE-NAME:#{uid}.ics\nEND:VEVENT\nEND:VCALENDAR")
     r = @c.find_event(uid)
     expect(r).to be
     expect(r.uid).to eq(uid)
  end

  it "find 2 events" do
    FakeWeb.register_uri(:report, "http://user@localhost:5232/user/calendar", body: File.open('spec/fixtures/report.xml'))
    r = @c.find_events(start: "2001-02-02 07:00", end: "2000-02-03 23:59")
    expect(r).to be
    expect(r.length).to eq 2
  end

  describe "info" do
    it "fetches the calendar info" do
      FakeWeb.register_uri(:propfind, "http://user@localhost:5232/user/calendar", body: File.open('spec/fixtures/calendar_info.xml') )
      info = @c.info
      expect(info[:displayname]).to eq("Test Calendar")
      expect(info[:ctag]).to eq("http://sabre.io/ns/sync/15")
    end
  end

end
