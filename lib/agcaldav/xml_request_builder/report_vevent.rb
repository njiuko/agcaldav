module AgCalDAV
  module XmlRequestBuilder

    class ReportVEVENT < Base
      attr_accessor :tstart, :tend

      def initialize( tstart=nil, tend=nil )
        @tstart = tstart
        @tend   = tend
        super()
      end

      def to_xml
        xml.c 'calendar-query'.intern, NAMESPACES do
          xml.d :prop do
            xml.d :getetag
            xml.c 'calendar-data'.intern
          end
          xml.c :filter do
            xml.c 'comp-filter'.intern, :name=> 'VCALENDAR' do
                xml.c 'comp-filter'.intern, :name=> 'VEVENT' do
                    xml.c 'time-range'.intern, :start=> "#{tstart}Z", :end=> "#{tend}Z"
                end
            end
          end
        end
      end
    end
  end
end
