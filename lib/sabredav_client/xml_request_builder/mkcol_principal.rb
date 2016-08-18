module SabredavClient
  module XmlRequestBuilder

    class MkcolPrincipal < Base
      attr_accessor  :email, :displayname

      def initialize(email,displayname)
        @email = email
        @displayname = displayname
        super()
      end

      def to_xml
        xml.d :mkcol, SB_NAMESPACES do
          xml.d :set do
            xml.d :prop do
              xml.d :resourcetype do
               xml.d :principal
             end
              xml.d :displayname, displayname unless displayname.to_s.empty?
              xml.tag! "sb:email-address", email
            end
          end
        end
      end
    end
  end
end
