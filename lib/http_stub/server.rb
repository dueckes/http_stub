require 'active_support/core_ext/module/aliasing'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/object/try'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/hash/deep_merge'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/hash/slice'

require_relative 'extensions/core/object'
require_relative 'extensions/core/hash/formatted'
require_relative 'extensions/core/hash/indifferent_and_insensitive_access'
require_relative 'extensions/core/hash/with_indifferent_and_insensitive_access'
require_relative 'extensions/core/hash'
require_relative 'extensions/core/uri'

require 'sinatra'
require_relative 'extensions/sinatra/namespace'
require 'sinatra/partial'
require 'json'
require 'json-schema'
require 'http_server_manager'
require 'method_source'
require 'haml'
require 'sass'

require_relative 'extensions/rack/handler'

require_relative 'server/stdout_logger'
require_relative 'server/request/parameters'
require_relative 'server/request/headers'
require_relative 'server/request/sinatra_request'
require_relative 'server/request/request'
require_relative 'server/request/factory'
require_relative 'server/registry'
require_relative 'server/stub/match/omitted_value_matcher'
require_relative 'server/stub/match/regexp_value_matcher'
require_relative 'server/stub/match/exact_value_matcher'
require_relative 'server/stub/match/string_value_matcher'
require_relative 'server/stub/match/hash_matcher'
require_relative 'server/stub/match/rule/truthy'
require_relative 'server/stub/match/rule/uri'
require_relative 'server/stub/match/rule/method'
require_relative 'server/stub/match/rule/headers'
require_relative 'server/stub/match/rule/parameters'
require_relative 'server/stub/match/rule/simple_body'
require_relative 'server/stub/match/rule/json_schema_body'
require_relative 'server/stub/match/rule/schema_body'
require_relative 'server/stub/match/rule/body'
require_relative 'server/stub/match/rules'
require_relative 'server/stub/response/headers'
require_relative 'server/stub/response/blocks'
require_relative 'server/stub/response/text_body'
require_relative 'server/stub/response/file_body'
require_relative 'server/stub/response/body'
require_relative 'server/stub/response/response'
require_relative 'server/stub/response'
require_relative 'server/response'
require_relative 'server/stub/triggers'
require_relative 'server/stub/stub'
require_relative 'server/stub/empty'
require_relative 'server/stub/match/match'
require_relative 'server/stub/match/miss'
require_relative 'server/stub/match/controller'
require_relative 'server/stub/registry'
require_relative 'server/stub/controller'
require_relative 'server/stub'
require_relative 'server/session'
require_relative 'server/session/identifier_strategy'
require_relative 'server/session/empty'
require_relative 'server/session/session'
require_relative 'server/session/registry'
require_relative 'server/session/controller'
require_relative 'server/scenario/links'
require_relative 'server/scenario/trigger'
require_relative 'server/scenario/not_found_error'
require_relative 'server/scenario/scenario'
require_relative 'server/scenario/registry'
require_relative 'server/scenario/controller'
require_relative 'server/scenario'
require_relative 'server/memory/initial_state'
require_relative 'server/memory/memory'
require_relative 'server/memory/controller'
require_relative 'server/application/request_support'
require_relative 'server/application/cross_origin_support'
require_relative 'server/application/session_uri_support'
require_relative 'server/application/text_formatting_support'
require_relative 'server/application/routes/resource'
require_relative 'server/application/routes/status'
require_relative 'server/application/routes/stub'
require_relative 'server/application/routes/session'
require_relative 'server/application/routes/scenario'
require_relative 'server/application/routes/memory'
require_relative 'server/application/application'
require_relative 'server/daemon'

module HttpStub

  module Server

    def self.start(configurator)
      HttpStub::Server::Application::Application.instance_eval do
        configure(configurator)
        run!
      end
    end

  end

end
