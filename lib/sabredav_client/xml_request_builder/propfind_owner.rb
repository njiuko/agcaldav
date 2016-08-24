module SabredavClient
  module XmlRequestBuilder

    class PropfindOwner < Base

      def initialize
        super()
      end

      def to_xml
        xml.d :propfind, NAMESPACE do
          xml.d :prop do
            xml.d :objectOwner
          end
        end
      end
    end
  end
end
