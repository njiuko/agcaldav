require 'builder'

module AgCalDAV
    NAMESPACES = { "xmlns:d" => 'DAV:', "xmlns:c" => "urn:ietf:params:xml:ns:caldav" }
    SHARING_NAMESPACES = {"xmlns:d" => 'DAV:', "xmlns:cs" => "http://calendarserver.org/ns/"}

    module Request
        class Base
            def initialize
                @xml = Builder::XmlMarkup.new(:indent => 2)
                @xml.instruct!
            end
            attr :xml
        end

        class PostSharing < Base
          attr_accessor :adds, :removes, :summary, :privilege, :common_name

          def initialize(adds = nil, summary = nil, common_name = nil, privilege = nil, removes = nil)
              puts adds
              @adds = adds || []
              @summary = summary
              @privilege = privilege
              @common_name = common_name
              @removes = removes || []
              super()
          end

          def to_xml
            xml.cs :share, SHARING_NAMESPACES do
              unless adds.empty?
                adds.each do |add|
                  add = "mailto:#{add}"
                  xml.cs :set do
                    xml.d :href, add
                    xml.cs :summary, summary unless summary.nil?
                    xml.tag! "cs:common-name", common_name unless common_name.nil?
                    xml.tag! "cs:#{privilege}"
                  end
                end
              end
              unless removes.empty?
                removes.each do |remove|
                  remove = "mailto:#{remove}"
                  xml.cs :remove do
                    xml.d :href, remove
                  end
                end
              end
            end
          end
        end

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

        class ReportVTODO < Base
            def to_xml
                xml.c 'calendar-query'.intern, NAMESPACES do
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
