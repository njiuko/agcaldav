module SabredavClient
  module XmlRequestBuilder

    class ProppatchPrincipal < Base
      attr_accessor :email, :displayname

      def initialize(email, displayname)
        @email       = email
        @displayname = displayname
        super()
      end

      def to_xml
        xml.d :propertyupdate, SB_NAMESPACES do
          xml.d :set do
            xml.d :prop do
              xml.tag! "sb:email-address", email unless email.empty?
              xml.d :displayname, displayname unless displayname.empty?
            end
          end
        end
      end
    end
  end
end
