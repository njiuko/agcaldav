module SabredavClient
  module XmlRequestBuilder

    class ReportVTODO < Base
      def to_xml
        xml.c 'calendar-query'.intern, C_NAMESPACES do
          xml.d :prop do
            xml.d :getetag
            xml.c 'calendar-data'.intern
          end
          xml.c :filter do
            xml.c 'comp-filter'.intern, :name=> 'VCALENDAR' do
                xml.c 'comp-filter'.intern, :name=> 'VTODO'
            end
          end
        end
      end
    end
  end
end
