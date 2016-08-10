module AgCalDAV
  module XmlRequestBuilder

    class Mkcalendar < Base
      attr_accessor :displayname, :description

      def initialize(displayname = nil, description = nil)
        @displayname = displayname
        @description = description
        super()
      end

      def to_xml
        xml.c :mkcalendar, NAMESPACES do
          xml.d :set do
            xml.d :prop do
              xml.d :displayname, displayname unless displayname.to_s.empty?
              xml.tag! "c:calendar-description", description, "xml:lang" => "en" unless description.to_s.empty?
            end
          end
        end
      end
    end
  end
end
