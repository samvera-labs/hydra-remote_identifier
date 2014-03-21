module Hydra
  module RemoteIdentifier
    class InvalidServiceMapping < RuntimeError
      def initialize(errors)
        super(errors.join(". ") << '.')
      end
    end

    class RemoteServiceError < RuntimeError
      def initialize(exception, uri, payload)
        @exception = exception
        @uri = uri
        @payload = payload
      end

      def to_s
        text = ""
        text << "response.code: #{response_code.inspect}\n"
        text << "response.body: #{response_body.inspect}\n"
        text << "\n"
        text << "request.uri: #{request_sanitized_uri.inspect}\n"
        text << "request.payload: #{request_sanitized_paylod.inspect}\n"
      end

      private
      def request_sanitized_paylod
        @payload
      end

      def request_sanitized_uri
        uri = URI.parse(@uri.to_s)
        x = "#{uri.scheme}://"
        x << "xxx:xxx@" if uri.user || uri.password
        x << File.join(uri.host, uri.path)
        x << '?' << uri.query if uri.query
        x
      end

      def response_code
        @exception.http_code rescue NoMethodError @exception.to_s
      end

      def response_body
        @exception.http_body rescue NoMethodError 'unknown'
      end
    end
  end
end
