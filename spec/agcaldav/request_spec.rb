require 'spec_helper'

RSpec.describe AgCalDAV::Request do
  let!(:client) { AgCalDAV::Client.new(:uri => "http://localhost:5232/user/calendar", :user => "user" , :password => "") }

  describe "initialize" do
    let!(:request) { AgCalDAV::Request.new(:get, client) }

    it "tests supported http methods" do
      methods = [:put, :get, :post, :mkcalendar, :propfind, :report, :delete, :mkcol]
      methods.each do |method|
        res = AgCalDAV::Request.new(method, client)
        expect(res).to be_a AgCalDAV::Request
      end
    end

    it "raises error if method not supported" do
      method = :foobar
      expect { res = AgCalDAV::Request.new(method, client)
      }.to raise_error AgCalDAV::Errors::HTTPMethodNotSupportedError
    end

    it "testes existence of http object" do
      expect(request.http).to be_a Net::HTTP
    end

    it "tests existence of path" do
      expect(request.path).to be
    end
  end

  describe "add" do
    let!(:request) { AgCalDAV::Request.new(:put, client, path: "random.ics") }

    it "header attributes" do
      request.add_header(content_type:    "application/xml",
                         content_length:  "xxxx",
                         if_match:        "etag",
                         dav:             "resource-must-be-null")
      req = request.request.to_hash
      expect(req["content-type"]).to   include "application/xml"
      expect(req["content-length"]).to include "xxxx"
      expect(req["if-match"]).to       include "etag"
      expect(req["dav"]).to            include "resource-must-be-null"
    end

    it "body" do
      body = "some content"
      request.add_body(body)
      expect(request.request.body).to eq body
    end
  end

end
