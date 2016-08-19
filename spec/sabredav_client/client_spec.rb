require 'spec_helper'

describe SabredavClient::Client do

  let!(:client) {  SabredavClient::Client.new(:uri => "http://localhost:5232/user/principals/user", :user => "user" , :password => "" ) }

  describe "initialization" do

    it "no encryption and basic_auth" do
      #TODO

    end

    it "with ssl and basic authentification" do
      client = SabredavClient::Client.new(:uri => "https://localhost:5232/user/principals/user", :user => "user" , :password => "" )

      expect(client.host).to be
      expect(client.port).to be
      expect(client.user).to be
      expect(client.base_path).to be
      expect(client.ssl).to be
      expect(client.password).to be
      expect(client.authtype).to eq("basic")
    end

    it "proxy usage" do
      #TODO
    end
  end

  describe "create_request" do

    it " with header and body" do
    method = :report
    body   = "xml_file"
    header = {content_type: "application/xml"}
    res = client.create_request(method, header: header, body: body)
    expect(res.request.body).to eq(body)
    expect(res.request.to_hash).to include("content-type" => ["application/xml"])
    end
  end
end
