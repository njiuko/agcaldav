module SabredavClient
  module XmlRequestBuilder

    NAMESPACE = {"xmlns:d" => 'DAV:'}
    C_NAMESPACES = {"xmlns:d" => 'DAV:', "xmlns:c" => "urn:ietf:params:xml:ns:caldav"}
    CS_NAMESPACES = {"xmlns:d" => 'DAV:', "xmlns:cs" => "http://calendarserver.org/ns/"}
    SB_NAMESPACES = {"xmlns:d" => 'DAV:', "xmlns:sb" =>  "http://sabredav.org/ns"}

    class Base
      def initialize
        @xml = Builder::XmlMarkup.new(:indent => 2)
        @xml.instruct!
      end
      attr :xml
    end
  end
end
