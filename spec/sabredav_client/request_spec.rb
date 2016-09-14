require 'spec_helper'

RSpec.describe SabredavClient::Request do
  let!(:connection_config) { SabredavClient::ConnectionConfig.new(:uri => "http://localhost:5232/user/calendar", :user => "user" , :password => "") }
  path = ""

  describe "initialize" do
    let!(:request) { SabredavClient::Request.new(connection_config, :get) }

    it "tests supported http methods" do
      methods = [:put, :get, :post, :mkcalendar, :propfind, :proppatch, :report, :delete, :mkcol]
      methods.each do |method|
        res = SabredavClient::Request.new(connection_config, method)
        expect(res).to be_a SabredavClient::Request
      end
    end

    it "raises error if method not supported" do
      method = :foobar
      expect { SabredavClient::Request.new(connection_config, method)
      }.to raise_error SabredavClient::Errors::HTTPMethodNotSupportedError
    end

    it "testes existence of http object" do
      expect(request.http).to be_a Net::HTTP
    end
  end

  describe "add" do
    let!(:request) { SabredavClient::Request.new(connection_config, :put, path: "random.ics") }

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
