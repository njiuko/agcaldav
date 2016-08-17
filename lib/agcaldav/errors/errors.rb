module AgCalDAV
  module Errors

    def  self.errorhandling response
      case response.code.to_i
      when 401
        raise AgCalDAV::Errors::AuthenticationError
      when 403
        raise AgCalDAV::Errors::ForbiddenError
      when 404
        raise AgCalDAV::Errors::NotFoundError
      when 405
        raise AgCalDAV::Errors::NotAllowedError
      when 410
        raise AgCalDAV::Errors::NotExistError
      when 412
        raise AgCalDAV::Errors::PreconditionFailed
      when 500
        raise AgCalDAV::Errors::APIError
      end
    end

    class AgCalDAVError < StandardError; end

    class PropertyNotSupportedError   < AgCalDAVError; end
    class ShareeTypeNotSupportedError < AgCalDAVError; end

    class HTTPMethodNotSupportedError < AgCalDAVError; end

    class APIError            < AgCalDAVError; end
    class ForbiddenError      < APIError; end
    class NotFoundError       < APIError; end
    class PreconditionFailed  < APIError; end
    class NotAllowedError     < APIError; end
    class AuthenticationError < APIError; end
    class NotExistError       < APIError; end
  end
end
