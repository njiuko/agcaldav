module SabredavClient
  module XmlRequestBuilder

    class ProppatchEventsOwner < Base
      attr_accessor :owner

      def initialize(owner)
        @owner = owner
        super()
      end

      def to_xml
        xml.d :propertyupdate, CS_NAMESPACES do
          xml.d :set do
            xml.d :prop do
              xml.cs :objectOwner, owner
            end
          end
        end
      end
    end
  end
end
