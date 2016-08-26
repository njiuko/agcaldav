module SabredavClient
  module XmlRequestBuilder

    class PropfindInvite < Base

      def initialize
        super()
      end

      def to_xml
        xml.d :propfind, CS_NAMESPACES do
          xml.d :prop do
            xml.cs :invite
          end
        end
      end
    end
  end
end
