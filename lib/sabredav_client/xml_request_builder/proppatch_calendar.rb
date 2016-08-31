module SabredavClient
  module XmlRequestBuilder

    class ProppatchCalendar < Base
      attr_accessor :displayname, :description

      def initialize(displayname = nil, description = nil)
        @displayname = displayname
        @description = description
        super()
      end

      def to_xml
        xml.d :propertyupdate, C_NAMESPACES do
          xml.d :set do
            xml.d :prop do
              xml.d :displayname, displayname unless displayname.nil?
              xml.tag! "c:calendar-description", description unless description.nil?
            end
          end
        end
      end
    end
  end
end
