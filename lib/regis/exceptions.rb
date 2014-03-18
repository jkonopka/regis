module Regis

  class Error < StandardError; end
  class ConfigurationError < Error; end
  class OverQueryLimitError < Error; end
  class RequestDenied < Error; end
  class InvalidRequest < Error; end
  class InvalidApiKey < Error; end
  class InvalidQueryError < Error; end
  class RateLimitedError < Error; end
  class ConnectionError < Error; end
  class InvalidResponseError < Error; end

end