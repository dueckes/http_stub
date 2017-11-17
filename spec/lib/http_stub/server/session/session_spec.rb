describe HttpStub::Server::Session::Session do

  let(:id)                { "some session id" }
  let(:scenario_registry) { instance_double(HttpStub::Server::Scenario::Registry) }
  let(:initial_stubs)     { (1..3).map { HttpStub::Server::StubFixture.create } }

  let(:stub_registry)       { instance_double(HttpStub::Server::Stub::Registry) }
  let(:stub_match_registry) { instance_double(HttpStub::Server::Registry) }
  let(:stub_miss_registry)  { instance_double(HttpStub::Server::Registry) }

  let(:logger) { instance_double(Logger) }

  let(:session) { described_class.new(id, scenario_registry, initial_stubs) }

  before(:example) do
    allow(HttpStub::Server::Stub::Registry).to receive(:new).and_return(stub_registry)
    allow(HttpStub::Server::Registry).to receive(:new).with("stub match").and_return(stub_match_registry)
    allow(HttpStub::Server::Registry).to receive(:new).with("stub miss").and_return(stub_miss_registry)
  end

  it "uses a stub registry that is initialized with the provided initial stubs" do
    expect(HttpStub::Server::Stub::Registry).to receive(:new).with(initial_stubs)

    session
  end

  describe "#id" do

    it "returns the provided id" do
      expect(session.id).to eql(id)
    end

  end

  describe "#matches?" do

    subject { session.matches?(provided_id, logger) }

    context "when the provided id is equal to the session id" do

      let(:provided_id) { id }

      it "returns true" do
        expect(subject).to be(true)
      end

    end

    context "when the provided id is not equal to the session id" do

      let(:provided_id) { "Another session id" }

      it "returns false" do
        expect(subject).to be(false)
      end

    end

  end

  describe "activate_scenario!" do

    let(:scenario_name) { "Some scenario name" }
    let(:scenario)      { nil }

    subject { session.activate_scenario!(scenario_name, logger) }

    before(:example) { allow(scenario_registry).to receive(:find).with(scenario_name, anything).and_return(scenario) }

    it "attempts to retrieve the scenario with the provided name from the scenario registry" do
      expect(scenario_registry).to receive(:find).with(scenario_name, logger)

      subject rescue nil
    end

    context "when the scenario is found" do

      let(:stubs_activated) { (1..3).map { HttpStub::Server::StubFixture.create } }
      let(:scenario)        { instance_double(HttpStub::Server::Scenario::Scenario) }

      before(:example) do
        allow(scenario_registry).to receive(:stubs_activated_by).and_return(stubs_activated)
        allow(stub_registry).to receive(:concat)
      end

      it "discovers the stubs activated by the scenario" do
        expect(scenario_registry).to receive(:stubs_activated_by).with(scenario, logger)

        subject
      end

      it "adds the stubs activated to the stub registry" do
        expect(stub_registry).to receive(:concat).with(stubs_activated, logger)

        subject
      end

    end

    context "when the scenario is not found" do

      let(:scenario) { nil }

      it "raises a scenario not found error with the provided name" do
        expect { subject }.to raise_error(HttpStub::Server::Scenario::NotFoundError, /#{scenario_name}/)
      end

    end

  end

  describe "#add_stub" do

    let(:the_stub) { instance_double(HttpStub::Server::Stub::Stub) }

    subject { session.add_stub(the_stub, logger) }

    it "adds the provided stub to the stub regsitry" do
      expect(stub_registry).to receive(:add).with(the_stub, logger)

      subject
    end

  end

  describe "#find_stub" do

    let(:id)       { SecureRandom.uuid }
    let(:the_stub) { instance_double(HttpStub::Server::Stub::Stub) }

    subject { session.find_stub(id, logger) }

    before(:example) { allow(stub_registry).to receive(:find).and_return(the_stub) }

    it "finds the stub with the provided id in the stub regsitry" do
      expect(stub_registry).to receive(:find).with(id, logger)

      subject
    end

    it "returns any found stub in the stub regsitry" do
      expect(subject).to eql(the_stub)
    end

  end

  describe "#stubs" do

    let(:the_stubs) { (1..3).map { instance_double(HttpStub::Server::Stub::Stub) } }

    subject { session.stubs }

    before(:example) { allow(stub_registry).to receive(:all).and_return(the_stubs) }

    it "finds all stubs in the stub regsitry" do
      expect(stub_registry).to receive(:all)

      subject
    end

    it "returns the stubs in the stub regsitry" do
      expect(subject).to eql(the_stubs)
    end

  end

  describe "#match" do

    let(:request) { instance_double(HttpStub::Server::Request::Request) }

    let(:matched_stub) { instance_double(HttpStub::Server::Stub::Stub) }

    subject { session.match(request, logger) }

    before(:example) { allow(stub_registry).to receive(:match).and_return(matched_stub) }

    it "delegates to the stub registry to match the request with a stub" do
      expect(stub_registry).to receive(:match).with(request, logger)

      subject
    end

    it "returns any matched stub" do
      expect(subject).to eql(matched_stub)
    end

  end

  describe "#add_match" do

    let(:triggered_scenario_names) { [] }
    let(:triggered_stubs)          { [] }
    let(:match_stub_triggers)      do
      instance_double(HttpStub::Server::Stub::Triggers, scenario_names: triggered_scenario_names,
                                                        stubs:          triggered_stubs)
    end
    let(:match_stub)               do
      instance_double(HttpStub::Server::Stub::Stub, triggers: match_stub_triggers)
    end
    let(:match)                    { instance_double(HttpStub::Server::Stub::Match::Match, stub: match_stub) }

    subject { session.add_match(match, logger) }

    before(:example) do
      allow(stub_match_registry).to receive(:add)
    end

    it "adds the match to the match registry" do
      expect(stub_match_registry).to receive(:add).with(match, logger)

      subject
    end

    context "when scenarios are to be triggered by the stub" do

      let(:triggered_scenario_names) { (1..3).map { |i| "triggered scenario #{i}" } }

      it "activates the scenarios in the session" do
        triggered_scenario_names.each do |scenario_name|
          expect(session).to receive(:activate_scenario!).with(scenario_name, logger)
        end

        subject
      end

    end

    context "when no scenarios are to be triggered by the stub" do

      let(:triggered_scenario_names) { [] }

      it "does not activate any scenarios in the session" do
        expect(session).to_not receive(:activate_scenario!)

        subject
      end

    end

    context "when stubs are to be triggered by the stub" do

      let(:triggered_stubs) { (1..3).map { instance_double(HttpStub::Server::Stub::Stub) } }

      it "adds the stubs to the session" do
        triggered_stubs.each { |triggered_stub| expect(session).to receive(:add_stub).with(triggered_stub, logger) }

        subject
      end

    end

    context "when no stubs are to be triggered by the stub" do

      let(:triggered_stubs) { [] }

      it "does not add any stubs to the session" do
        expect(session).to_not receive(:add_stub)

        subject
      end

    end

  end

  describe "#matches" do

    let(:stub_matches) { (1..3).map { instance_double(HttpStub::Server::Stub::Match::Match) } }

    subject { session.matches }

    before(:example) { allow(stub_match_registry).to receive(:all).and_return(stub_matches) }

    it "retrieves all the matches in the stub match registry" do
      expect(stub_match_registry).to receive(:all)

      subject
    end

    it "returns any matches" do
      expect(subject).to eql(stub_matches)
    end

  end

  describe "#last_match" do

    let(:match_args) { { uri: "some uri", method: "some method" } }

    let(:stub_match) { instance_double(HttpStub::Server::Stub::Match::Match) }

    subject { session.last_match(match_args, logger) }

    before(:example) { allow(stub_match_registry).to receive(:find).and_return(stub_match) }

    it "retrieves the match for the provided URI and method via the stub match registry" do
      expect(stub_match_registry).to receive(:find).with(match_args, logger)

      subject
    end

    it "returns any match" do
      expect(subject).to eql(stub_match)
    end

  end

  describe "#add_miss" do

    let(:stub_miss) { instance_double(HttpStub::Server::Stub::Match::Miss) }

    subject { session.add_miss(stub_miss, logger) }

    it "adds the miss to the stub miss registry" do
      expect(stub_miss_registry).to receive(:add).with(stub_miss, logger)

      subject
    end

  end

  describe "#misses" do

    let(:stub_misses) { (1..3).map { instance_double(HttpStub::Server::Stub::Match::Miss) } }

    subject { session.misses }

    before(:example) { allow(stub_miss_registry).to receive(:all).and_return(stub_misses) }

    it "retrieves all the misses in the stub miss registry" do
      expect(stub_miss_registry).to receive(:all)

      subject
    end

    it "returns any misses" do
      expect(subject).to eql(stub_misses)
    end

  end

  describe "#reset" do

    subject { session.reset(logger) }

    before(:example) do
      allow(stub_registry).to receive(:reset)
      allow(stub_match_registry).to receive(:clear)
      allow(stub_miss_registry).to receive(:clear)
    end

    it "resets the stub registry to revert it to its original state" do
      expect(stub_registry).to receive(:reset).with(logger)

      subject
    end

    it "clears the stub miss registry to revert it to its original state" do
      expect(stub_miss_registry).to receive(:clear).with(logger)

      subject
    end

    it "clears the stub match registry to revert it to its original state" do
      expect(stub_match_registry).to receive(:clear).with(logger)

      subject
    end

    it "clears stub misses before the resetting stubs" do
      expect(stub_miss_registry).to receive(:clear).ordered
      expect(stub_registry).to receive(:reset).ordered

      subject
    end

    it "clears stub matches before the resetting stubs" do
      expect(stub_match_registry).to receive(:clear).ordered
      expect(stub_registry).to receive(:reset).ordered

      subject
    end

  end

end
