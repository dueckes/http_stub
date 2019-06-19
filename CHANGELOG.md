** 0.28.0.beta3 **

Breaking:
* Dropped Ruby 2.2 support (encouraged by Bundler)

Misc:
* Upgraded dependencies 

** 0.28.0.beta2 **

Fix:
* Accommodates stub responses that are frozen

Misc:
* Upgraded dependencies, migrated to Sinatra 2.0 

** 0.28.0.beta1 **

This release removes the ability to define Scenario's and Stubs on-the-fly over HTTP.
These can now solely be defined via the DSL.<br/>
This change intends to encourage the production of _verifiable contracts_.

This release also brings the ability to respond dynamically to a matching request by providing a response block.
The blocks can interpolate any part of the request into the response.<br/>

New:
* `stub.respond_with(&block)` dynamically invokes the block on each match
* `HttpStub::Client` provides a DSL over the servers HTTP API to enable Scenario's and manipulate sessions

Breaking:
* `HttpStub::Configurer` renamed to `HttpStub::Configurator`
* A scenario is immediately activated via `scenario.activate!`
  * A scenario activates other scenarios via `scenario.activate_scenarios!`
* Scenario's and Stubs are no longer configurable over HTTP, they are loaded in-process on the server
  * `HttpStub::Configurator` no longer requires initialization, `#self.on_initialize` is no longer supported
  * `server:configure` rake task has been removed
  * `stub_server.has_started!` has been removed
  * Scenario's can no longer be cleared
* `stub_server` no longer supports `host=`, running host defaults to `localhost`

** 0.27.0 **

Breaking:
* Supported Ruby versions now >= 2.2.2 (as per Rails)

Misc:
* Upgraded to activesupport 5.0 and json 2.0 

** 0.26.2 **

Fix:
* Accommodates numeric stub response header values

** 0.26.1 **

New:
* `GET /http_stub/status` indicates the status of the server
 
Fix:
* Stub match lists are empty on start-up

** 0.26.0 **

New:
* `stub.trigger` can activate Scenarios
* Stub sessions are enabled via `stub_server.session_identifier`, sessions can pinned to a request header or parameter
* `stub_server.session(id)` allows stub and scenario interactions within an isolated session
* `stub_server.reset!` returns the server to it's uninitialized original state
* `GET /http_stub/memory` shows the memory session content

Breaking:
* `stub.trigger` accepts a hash with optional `:scenarios`, `:scenario`, `:stubs` and `:stub` elements
* Removed deprecated `Configurer` behaviour:
** Replace `server_has_started!` with `stub_server.has_started!`
** Replace `stub_activator` with `stub_server.add_scenario!`
** Replace `clear_activators!` with `stub_server.clear_scenarios!`
** Replace `stub_response!` with `stub_server.add_stub!`
** Methods directly accessible from `Configurer` must now be performed via `stub_server`, e.g. `stub_server.recall_stubs!`

Misc:
* Administration pages:
  * `GET /http_stub` shows all sessions when sessions are enabled, show transaction session when sessions are disabled 
* Refactor:
  * Migrated to Sinatra namespaces
  * Introduced concept of server `memory` holding all scenarios and sessions
  * `memory` session holds the initial state of the server, all other sessions are derived from this
  * In session-less mode, a `transactional` session is used internally by default

** 0.25.1 **

Fix:
* Removed `active_support/json/encoding` dependency as it can inadvertently impact JSON defined in `Configurer`s

** 0.25.0 **

New:
* `GET /http_stub/stubs/matches/last?method=<HTTP method>&uri=<URI part>` retrieves the last match for an endpoint

Misc:
* Administration pages:
  * Matches and misses are listed separately
  * Scenarios are activated in-page
* Refactor:
  * Stubs contain match rules
  * Stub payload is passed through a chain of modifiers

** 0.24.3 **

Fix:
* File responses honour `If-Modified-Since` header

Breaking:
* Response status is no longer configurable when responding with files.  A 200 status is the standard response.
  A 304 status will be returned if an appropriate `if_modified_since` header is issued.

** 0.24.2 **

Fix:
* Honours cross-origin pre-flight requests

** 0.24.1 **

Breaking:
* Dropped Ruby 1.9.3 support (encouraged by `json` gem)

** 0.24.0 **

New:
* Cross-origin resource sharing support via `stub_server.enable :cross_origin_support`

** 0.23.1 **

New:
* `GET /http_stub/stubs/matches` displays the calculated response for stubs whose response has request references

** 0.23.0 **

New:
* Stub response headers and body can contain request header and parameter values
  * e.g. `stub.respond_with { |request| { headers: { location: request.parameter[:redirect_uri] } }`

Misc:
* Introduced [RuboCop](https://github.com/bbatsov/rubocop) source code analysis

** 0.22.4 **

New:
* ```stub_server.external_base_uri``` facilitates links to a stub running in a Docker container
  * Set the external base URI via the environment variable ```STUB_EXTERNAL_BASE_URI```

** 0.22.3 **

Breaking:
* Disabled security measures provided by `Sinatra` and `Rack::Protection` (e.g. `JsonCsrf`, `HttpOrigin`, `RemoteToken`)
  * Stubs can emulate a desired behaviour in stubbed responses

New:
* `stub.respond_with(json: { key: "value" })` supported

Misc:
* Administration page formatting improvements

** 0.22.2 **

Fix:
* Tolerates `rake >= 10.4`

** 0.22.1 **

New:
* `GET /http_stub/stubs/matches` explicitly lists stub matches and misses

** 0.22.0 **

Breaking:
* `POST /http_stub/scenarios/activate` with scenario name parameter activates scenario

New:
* `GET /http_stub/scenarios?name=<scenario name>` retrieves details of scenario with matching name
* Scenario list page contains summary information, with links to activate and view details

Misc:
* Refactor: Scenario names preferred over ID, natural language preferred

** 0.21.0 **

Breaking:
* All administration endpoints are prefixed with 'http_stub', including POSTed configuration

** 0.20.1 **

New:
* Presentation of stubs tweaked in diagnostic pages
* `GET /stubs/matches` includes response data

** 0.20.0 **

New:
* `GET /stubs/matches` lists stub match history
* `DELETE /stubs` also clears matches
* `GET /stubs/:id` displays a stub
* `add_stub!` returns POST /stubs response when configurer has been initialized

Misc:
* Refactor: Introduced `HttpStub::Server::Stub::Match` to encapsulate match logic and rules

** 0.19.2 **

Misc:
* Refactor: Class name mirroring module name preferred over Instance (for aggregates).

** 0.19.1 **

New:
* `add_scenario_with_one_stub!` supports builder as an argument.

** 0.19.0 **

New:
* Server request defaults support.

Breaking:
* ```match_requests` no longer accepts uri as first argument.  It must be provided in the argument hash, e.g. `stub.match_requests(uri: "/some/uri")`
* `add_scenario_with_one_stub!` preferred over `add_one_stub_scenario!`

** 0.18.2 **

New:
* Endpoint templates support building and adding stub to server.

** 0.18.1 **

New:
* Scenarios added via an endpoint template can exclude block

** 0.18.0 **

New:
* `stub_server.endpoint_template` scenario creation support
* `stub_server.add_one_stub_scenario!` simplifies DSL
* `HttpStub::Configurer::Part` aids composing large Configurers

** 0.17.0 **

New:
* request body matching via exact match, regex match and JSON schema validation match.

Breaking:
* `Configurer` host, port and base_uri related methods must now be accessed via the `stub_server`.

** 0.16.0 **

New:
* scenarios

Deprecated:
* stub activators

Breaking:
* Activator paths replaced by activator names.  Calls to `stub_activator` and `activate!` must no longer have '/' prefix.

** 0.12.0 **

Breaking:
* Daemon renamed to ServerDaemon for clarity.
