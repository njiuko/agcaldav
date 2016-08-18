module SabredavClient
  module XmlRequestBuilder
    class ReportEventChanges < Base
      attr_accessor :sync_token

      def initialize(sync_token)
        @sync_token = sync_token
        super()
      end

      def to_xml
        xml.tag! "d:sync-collection", NAMESPACE do
          xml.tag! "d:sync-token", sync_token
          xml.tag! "d:sync-level", "1"
          xml.d :prop do
            xml.d :getetag
          end
        end
      end
    end
  end
end
