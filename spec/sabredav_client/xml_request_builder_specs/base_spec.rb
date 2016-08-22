require 'spec_helper'

describe SabredavClient::XmlRequestBuilder::Base do

  let(:base) { described_class.new() }

  describe "module constants" do

    it "to be there" do
      NAMESPACE = {"xmlns:d" => 'DAV:'}
      C_NAMESPACES = {"xmlns:d" => 'DAV:', "xmlns:c" => "urn:ietf:params:xml:ns:caldav"}
      CS_NAMESPACES = {"xmlns:d" => 'DAV:', "xmlns:cs" => "http://calendarserver.org/ns/"}
      SB_NAMESPACES = {"xmlns:d" => 'DAV:', "xmlns:sb" =>  "http://sabredav.org/ns"}

      expect(SabredavClient::XmlRequestBuilder::NAMESPACE).to eq NAMESPACE
      expect(SabredavClient::XmlRequestBuilder::C_NAMESPACES).to eq C_NAMESPACES
      expect(SabredavClient::XmlRequestBuilder::CS_NAMESPACES).to eq CS_NAMESPACES
      expect(SabredavClient::XmlRequestBuilder::SB_NAMESPACES).to eq SB_NAMESPACES
    end
  end

  describe "initialization" do
    indent = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<kind_of?>Builder::XmlMarkup</kind_of?>\n<indent/>\n"

    it "xml indent is correct" do
      expect(base.xml).to be_a Builder::XmlMarkup
      expect(base.xml.indent).to eq indent
    end
  end
end
