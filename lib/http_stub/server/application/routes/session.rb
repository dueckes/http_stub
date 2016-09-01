module HttpStub
  module Server
    module Application
      module Routes

        module Session

          NAMESPACE_URI       = "/http_stub/sessions".freeze
          DEFAULT_SESSION_URI = "#{NAMESPACE_URI}/#{HttpStub::Server::Session::DEFAULT_ID}".freeze

          private_constant :NAMESPACE_URI, :DEFAULT_SESSION_URI

          def initialize
            super()
            @session_controller = HttpStub::Server::Session::Controller.new(@session_registry)
          end

          def self.included(application)
            application.instance_eval do

              get "/http_stub" do
                redirect settings.session_identifier? ? NAMESPACE_URI : DEFAULT_SESSION_URI
              end

              namespace NAMESPACE_URI do

                get do
                  haml :sessions, {}, sessions: @session_controller.find_all
                end

                get "/:id" do
                  establish_request
                  haml :session, {}, session: @session_controller.find(@http_stub_request, logger)
                end

              end

            end
          end

        end

      end
    end
  end
end
