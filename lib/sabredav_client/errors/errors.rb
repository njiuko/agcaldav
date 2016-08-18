module SabredavClient
  module Errors

    def  self.errorhandling response
      case response.code.to_i
      when 401
        raise SabredavClient::Errors::AuthenticationError
      when 403
        raise SabredavClient::Errors::ForbiddenError
      when 404
        raise SabredavClient::Errors::NotFoundError
      when 405
        raise SabredavClient::Errors::NotAllowedError
      when 410
        raise SabredavClient::Errors::NotExistError
      when 412
        raise SabredavClient::Errors::PreconditionFailed
      when 500
        raise SabredavClient::Errors::APIError
      end
    end

    class SabredavClientError < StandardError; end

    class PropertyNotSupportedError   < SabredavClientError; end
    class ShareeTypeNotSupportedError < SabredavClientError; end

    class HTTPMethodNotSupportedError < SabredavClientError; end

    class APIError            < SabredavClientError; end
    class ForbiddenError      < APIError; end
    class NotFoundError       < APIError; end
    class PreconditionFailed  < APIError; end
    class NotAllowedError     < APIError; end
    class AuthenticationError < APIError; end
    class NotExistError       < APIError; end
  end
end
