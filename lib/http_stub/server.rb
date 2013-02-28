module HttpStub

  class Server < ::Sinatra::Base

    register Sinatra::Partial

    enable :dump_errors, :logging, :partial_underscores

    def initialize
      super()
      @stub_registry = HttpStub::Models::Registry.new("stub")
      @alias_registry = HttpStub::Models::Registry.new("alias")
      @stub_controller = HttpStub::Controllers::StubController.new(@stub_registry)
      @alias_controller = HttpStub::Controllers::AliasController.new(@alias_registry, @stub_registry)
    end

    private

    SUPPORTED_REQUEST_TYPES = [:get, :post, :put, :delete, :patch, :options].freeze

    def self.any_request_type(path, opts={}, &block)
      SUPPORTED_REQUEST_TYPES.each { |type| self.send(type, path, opts, &block) }
    end

    public

    # Sample request body:
    # {
    #   "uri": "/some/path",
    #   "method": "get",
    #   "parameters": {
    #     "key": "value",
    #     ...
    #   },
    #   "response": {
    #     "status": "200",
    #     "body": "Hello World"
    #   }
    # }
    post "/stubs" do
      response = @stub_controller.register(request)
      halt(response.status, response.body)
    end

    get "/stubs" do
      haml :stubs, {}, stubs: @stub_registry.all
    end

    delete "/stubs" do
      @stub_controller.clear(request)
      halt 200
    end

    # Sample request body:
    # {
    #   "alias_uri": "/some/path",
    #   ... see /stub ...
    # }
    post "/stubs/aliases" do
      response = @alias_controller.register(request)
      halt(response.status, response.body)
    end

    get "/stubs/aliases" do
      haml :aliases, {}, aliases: @alias_registry.all.sort_by(&:alias_uri)
    end

    delete "/stubs/aliases" do
      @alias_controller.clear(request)
      halt 200
    end

    get "/application.css" do
      sass :application
    end

    any_request_type(//) { handle_request }

    helpers do

      def h(text)
        Rack::Utils.escape_html(text)
      end

    end

    private

    def handle_request
      response = @stub_controller.replay(request)
      response = @alias_controller.activate(request) if response.empty?
      response = HttpStub::Response::ERROR if response.empty?
      halt(response.status, response.body)
    end

  end

end
