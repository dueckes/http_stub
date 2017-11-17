module HttpStub
  module Server
    module Stub

      class Controller

        def match(request, logger)
          stub = request.session.match(request, logger)
          response = stub ? stub.response_for(request) : HttpStub::Server::Response::NOT_FOUND
          request.session.add_match(HttpStub::Server::Stub::Match::Match.new(request, response, stub), logger) if stub
          request.session.add_miss(HttpStub::Server::Stub::Match::Miss.new(request), logger) unless stub
          response
        end

        def find(request, logger)
          request.session.find_stub(request.parameters[:stub_id], logger)
        end

        def find_all(request)
          request.session.stubs
        end

        def reset(request, logger)
          request.session.reset(logger)
        end

      end

    end
  end
end
