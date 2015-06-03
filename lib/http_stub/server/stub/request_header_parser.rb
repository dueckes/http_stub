module HttpStub
  module Server
    module Stub

      class RequestHeaderParser

        def self.parse(request)
          request.env.reduce({}) do |result, element|
            match = element[0].match(/^(?:HTTP_)?([A-Z0-9_]+)$/)
            result[match[1]] = element[1] if match
            result
          end
        end

      end

    end
  end
end
