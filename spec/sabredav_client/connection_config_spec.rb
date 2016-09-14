require 'spec_helper'

describe SabredavClient::ConnectionConfig do

  let!(:connection_config) {  SabredavClient::ConnectionConfig.new(:uri => "http://localhost:5232/user/principals/user", :user => "user" , :password => "" ) }

  describe "initialization" do

    it "no encryption and basic_auth" do
      #TODO
    end

    it "with ssl and basic authentification" do
      connection_config = SabredavClient::ConnectionConfig.new(:uri => "https://localhost:5232/user/principals/user", :user => "user" , :password => "" )

      expect(connection_config.host).to be
      expect(connection_config.port).to be
      expect(connection_config.user).to be
      expect(connection_config.base_path).to be
      expect(connection_config.ssl).to be
      expect(connection_config.password).to be
      expect(connection_config.authtype).to eq("basic")
    end

    it "proxy usage" do
      #TODO
    end
  end
end
