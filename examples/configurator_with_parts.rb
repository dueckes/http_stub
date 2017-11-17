module HttpStub
  module Examples

    class ConfiguratorWithParts
      include HttpStub::Configurator

      class PartWithCallbacks
        include HttpStub::Configurator::Part

        def configure_some_stub
          stub_server.add_stub! do |stub|
            stub.match_requests(uri: "/registered_in_configure_stub_method", method: :get)
            stub.respond_with(body: "configured stub response")
          end
        end

        def configure_some_stubs
          stub_server.add_stub! do |stub|
            stub.match_requests(uri: "/registered_in_configure_stubs_method", method: :get)
            stub.respond_with(body: "configured stubs response")
          end
        end

        def configure_some_scenario
          stub_server.add_scenario_with_one_stub!("Some scenario") do |stub, scenario|
            stub.match_requests(uri: "/registered_in_configure_scenario_method", method: :get)
            stub.respond_with(body: "configured scenario response")
            scenario.activate!
          end
        end

        def configure_some_scenarios
          stub_server.add_scenario_with_one_stub!("Some scenarios") do |stub, scenario|
            stub.match_requests(uri: "/registered_in_configure_scenarios_method", method: :get)
            stub.respond_with(body: "configured scenarios response")
            scenario.activate!
          end
        end

      end

      class AnotherPart
        include HttpStub::Configurator::Part

        def add_stub
          stub_server.add_stub! do |stub|
            stub.match_requests(uri: "/registered_in_another_part", method: :get)
            stub.respond_with(body: "response from another part")
          end
        end

      end

      class PartCallingAnotherPart
        include HttpStub::Configurator::Part

        def configure_another_stub
          another_part.add_stub
        end

      end

      self.parts = {
        part_with_callbacks:       PartWithCallbacks.new,
        another_part:              AnotherPart.new,
        part_calling_another_part: PartCallingAnotherPart.new
      }

    end

  end
end
