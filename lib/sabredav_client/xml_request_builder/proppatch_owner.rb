module SabredavClient
  module XmlRequestBuilder

    class ProppatchOwner < Base
      attr_accessor :owner

      def initialize(owner)
        @owner = owner
        super()
      end

      def to_xml
        xml.d :propertyupdate, NAMESPACE do
          xml.d :set do
            xml.d :prop do
              xml.d :objectOwner, owner
            end
          end
        end
      end
    end
  end
end
