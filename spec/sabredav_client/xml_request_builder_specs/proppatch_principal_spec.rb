require 'spec_helper'

RSpec.describe SabredavClient::XmlRequestBuilder::ProppatchPrincipal do

  let(:proppatch) { described_class.new(email = "update@test.de", diplayname = "David B." ) }

  describe "#to_xml" do
    let(:expected_xml) { File.read('spec/fixtures/xml_request_builder/proppatch_principal.xml') }

    it "returns a valid xml" do
      expect(proppatch.to_xml).to eq(expected_xml)
    end

    it "returns a valid xml without email address" do
      proppatch.email = ""
      expect(proppatch.to_xml).not_to include("sb:email-address")
    end

    it "returns a valid xml without displayname" do
      proppatch.displayname = ""
      expect(proppatch.to_xml).not_to include("d:displayname")
    end
  end
end
