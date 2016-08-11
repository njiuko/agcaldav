module AgCalDAV
  module Errors
    class AgCalDAVError < StandardError; end

    class PropertyNotSupportedError   < AgCalDAVError; end
    class ShareeTypeNotSupportedError < AgCalDAVError; end

    class HTTPMethodNotSupportedError < AgCalDAVError; end

    class APIError            < AgCalDAVError; end

    class NotFoundError       < APIError; end
    class PreconditionFailed  < APIError; end
    class NotAllowedError     < APIError; end
    class AuthenticationError < APIError; end
    class NotExistError       < APIError; end

  end
end

