require 'spec_helper'

describe SabredavClient::Events do
  client = SabredavClient::Client.new(uri: "http://localhost:5232/user/calendar", user: "user", password: "")
  let!(:events) { described_class.new(client = client) }

  describe "initialization" do

    it "client" do
      expect(events.client).to be_a(SabredavClient::Client)
    end
  end

  describe "delete" do

    it "one event" do
      uri = "event.ics"
      FakeWeb.register_uri(:delete, "http://user@localhost:5232/user/calendar/#{uri}",
                           [{:body => "1 deleted.", :status => ["200", "OK"]},
                            {:body => "not found",  :status => ["404", "Not Found"]}])
      r = events.delete(uri)
      expect(r).to be(true)
      expect {
        events.delete(uri)
      }.to raise_error(SabredavClient::Errors::NotFoundError)
    end
  end

  describe "find one event" do

    it "one event" do
      uid = "47732F70-1793-47B3-80FA-57E3C5ECA0E5"
      uri = "#{uid}.ics"
      FakeWeb.register_uri(:get, "http://user@localhost:5232/user/calendar/#{uri}", :body => File.open("spec/fixtures/event.ics"))
       r = events.find(uri)
       expect(r).to be_a(String)
    end

    it "two events" do
      FakeWeb.register_uri(:report, "http://user@localhost:5232/user/calendar/", body: File.open('spec/fixtures/events_find_multiple.xml'))
      r = events.find_multiple(starts: "2001-02-02 07:00", ends: "2000-02-03 23:59")
      expect(r.first).to be_a(Icalendar::Event)
      expect(r.length).to eq 2
    end
  end

  describe "create_update" do
    etag      = "123"
    uri       = "event.ics"
    event_ics =  File.open('spec/fixtures/event.ics')

    it "create event" do
      FakeWeb.register_uri(:put, "http://user@localhost:5232/user/calendar/#{uri}", {etag: etag, status: ["201", "OK"]})
      r = events.create_update(uri, event_ics.to_s)
      expect(r).to eq etag
    end

    it "update event" do
      new_etag = "124"
      FakeWeb.register_uri(:put, "http://user@localhost:5232/user/calendar/#{uri}", {status: ["200", "OK"], etag: new_etag})
      r = events.create_update(uri, event_ics.to_s, etag )
      expect(r).not_to eq etag
    end
  end

  describe "owner" do
    uri = "event.ics"

    it "find" do
      owner = "principals/usertest"
      FakeWeb.register_uri(:propfind, "http://user@localhost:5232/user/calendar/#{uri}", {status: ["200", "OK"], body: File.open("spec/fixtures/events_owner.xml") })
      r = events.owner(uri)

      expect(r).to eq(owner)
    end

    it "update" do

      FakeWeb.register_uri(:proppatch, "http://user@localhost:5232/user/calendar/#{uri}", {status: ["200", "OK"]})
      r = events.update_owner(uri, "principals/usertest")

      expect(r).to be
    end

  end
end
