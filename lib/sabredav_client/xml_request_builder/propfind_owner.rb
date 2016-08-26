module SabredavClient
  module XmlRequestBuilder

    class PropfindOwner < Base

      def initialize
        super()
      end

      def to_xml
        xml.d :propfind, CS_NAMESPACES do
          xml.d :prop do
            xml.cs :objectOwner
          end
        end
      end
    end
  end
end
