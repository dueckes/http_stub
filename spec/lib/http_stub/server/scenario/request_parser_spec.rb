describe HttpStub::Server::Scenario::RequestParser do

  let(:request_parser) { described_class }

  describe "::parse" do

    let(:params)    { {} }
    let(:body_hash) { {} }
    let(:request)   { instance_double(Rack::Request, params: params, body: StringIO.new(body_hash.to_json)) }

    subject { request_parser.parse(request) }

    context "when the request contains many stubs" do

      let(:payload)       { HttpStub::ScenarioFixture.new.with_stubs!(3).server_payload }
      let(:stub_payloads) { payload["stubs"] }
      let(:params)        { { "payload" => payload.to_json } }

      it "consolidates any files into each stub payload" do
        stub_payloads.each do |stub_payload|
          expect(HttpStub::Server::Stub::PayloadFileConsolidator).to receive(:consolidate!).with(stub_payload, request)
        end

        subject
      end

      it "consolidates any files in each stub payload" do
        stub_payloads.each_with_index.each do |stub_payload|
          allow(HttpStub::Server::Stub::PayloadFileConsolidator).to receive(:consolidate!).with(stub_payload, anything)
        end

        expect(subject).to eql(payload)
      end

    end

    context "when the request contains one stub" do

      let(:payload)      { HttpStub::ScenarioFixture.new.with_stubs!(1).server_payload }
      let(:stub_payload) { payload["stubs"].first }
      let(:params)       { { "payload" => payload.to_json } }

      it "consolidates any file into the stub payload" do
        expect(HttpStub::Server::Stub::PayloadFileConsolidator).to receive(:consolidate!).with(stub_payload, request)

        subject
      end

      it "consolidates any file in the stub payload" do
        allow(HttpStub::Server::Stub::PayloadFileConsolidator).to receive(:consolidate!).with(stub_payload, anything)

        expect(subject).to eql(payload)
      end

    end

  end

end