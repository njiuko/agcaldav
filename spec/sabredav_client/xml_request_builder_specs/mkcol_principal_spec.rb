require 'spec_helper'

RSpec.describe SabredavClient::XmlRequestBuilder::MkcolPrincipal do
  let(:mkcol) { described_class.new(email = "test@test.de", displayname = "usertest") }

  describe "#to_xml" do
    let(:expected_xml) { File.read('spec/fixtures/xml_request_builder/mkcol_principal.xml') }

    it "returns a valid xml with displayname" do
      expect(mkcol.to_xml).to eq(expected_xml)
    end
  end
end
