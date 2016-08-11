module AgCalDAV
  module Errors
    class AgCalDAVError < StandardError; end

    class TypeNotSupportedError    < AgCalDAVError; end
    class NotFoundError       < AgCalDAVError; end
    class PreconditionFailed  < AgCalDAVError; end
    class NotAllowedError     < AgCalDAVError; end
    class AuthenticationError < AgCalDAVError; end
    class DuplicateError      < AgCalDAVError; end
    class APIError            < AgCalDAVError; end
    class NotExistError       < AgCalDAVError; end

    class PropertyNotSupportedError < AgCalDAVError; end
  end
end

