require 'spec_helper'

describe SabredavClient::Principal do

  let(:principal) { SabredavClient::Principal.new(:uri => "http://localhost:5232/user/principals/user", :user => "user" , :password => "") }

  describe "initialization" do

    it "client available" do
      expect(principal.connection_config).to be_a(SabredavClient::ConnectionConfig)
    end
  end

  describe "create" do
    email = "test@mail.de"
    description = "a random description"

    it "create with description" do
        FakeWeb.register_uri(:mkcol, "http://user@localhost:5232/user/principals/user/", status: ["201", "Created"])
        result = principal.create(email, description)
        expect(result).to be
    end

    it "create without description" do
      FakeWeb.register_uri(:mkcol, "http://user@localhost:5232/user/principals/user/", status: ["201", "Created"])
      result = principal.create(email)
      expect(result).to be
    end

    it "create fails because resource already exists" do
      FakeWeb.register_uri(:mkcol, "http://user@localhost:5232/user/principals/user/", status: ["405", "Method not allowed"])
      expect {
        principal.create(email)
      }.to raise_error(SabredavClient::Errors::NotAllowedError)
    end
  end

  describe "update" do

    it "updates email and displayname" do
      email       = "update@test.de"
      displayname = "David B."
      FakeWeb.register_uri(:proppatch, "http://user@localhost:5232/user/principals/user/", status: ["207", "OK"])

      result = principal.update(email: email, displayname: displayname)
      expect(result).to be

    end
  end
end
