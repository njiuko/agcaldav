module SabredavClient
  module XmlRequestBuilder

    class ProppatchCalendar < Base
      attr_accessor :privilege, :displayname, :description

      def initialize(displayname = nil, description = nil, privilege = nil)
        @displayname = displayname
        @description = description
        @privilege   = privilege
        super()
      end

      def to_xml
        xml.d :propertyupdate, NAMESPACE.merge(C_NAMESPACES).merge(CS_NAMESPACES) do
          xml.d :set do
            xml.d :prop do
              xml.d :displayname, displayname unless displayname.nil?
              xml.tag! "c:calendar-description", description unless description.nil?
              unless privilege.nil?
                xml.cs :access do
                  xml.tag! "cs:#{privilege}"
                end
              end
            end
          end
        end
      end
    end
  end
end
